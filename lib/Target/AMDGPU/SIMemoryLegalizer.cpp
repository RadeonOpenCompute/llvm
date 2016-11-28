//===--- SIMemoryLegalizer.cpp - Legalizes memory operations --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
/// \brief Legalizes memory operations.
//
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "AMDGPUSubtarget.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/IR/DiagnosticInfo.h"
using namespace llvm;

#define DEBUG_TYPE "si-memory-legalizer"
#define PASS_NAME "SI Memory Legalizer"

namespace {

class SIMemoryLegalizer final : public MachineFunctionPass {
private:
  /// \brief Immediate for "vmcnt(0)".
  static const unsigned Vmcnt0;

  /// \brief Target instruction info.
  const SIInstrInfo *TII;
  /// \brief LLVM context.
  LLVMContext *CTX;
  /// \brief List of atomic pseudo machine instructions.
  std::list<MachineBasicBlock::iterator> AtomicPseudoMI;

  /// \brief Inserts "buffer_wbinvl1_vol" instruction before \p MI. Always
  /// returns true.
  bool insertBufferWbinvl1Vol(const MachineBasicBlock::iterator &MI) const;
  /// \brief Inserts "s_waitcnt vmcnt(0)" instruction before \p MI. Always
  /// returns true.
  bool insertWaitcntVmcnt0(const MachineBasicBlock::iterator &MI) const;

  /// \brief Sets GLC bit if present in \p MI. Returns true if \p MI is
  /// modified, false otherwise.
  bool setGLC(const MachineBasicBlock::iterator &MI) const;

  /// \brief Removes all processed atomic pseudo machine instructions from the
  /// current function. Returns true if current function is modified, false
  /// otherwise.
  bool removeAtomicPseudoMI();

  /// \brief Reports unknown synchronization scope used in \p MI to LLVM
  /// context.
  void reportUnknownSynchScope(const MachineBasicBlock::iterator &MI);

  /// \returns True if \p MI is atomic fence operation, false otherwise.
  bool isAtomicFence(const MachineBasicBlock::iterator &MI) const;
  /// \returns True if \p MI is atomic load operation, false otherwise.
  bool isAtomicLoad(const MachineBasicBlock::iterator &MI) const;
  /// \returns True if \p MI is atomic store operation, false otherwise.
  bool isAtomicStore(const MachineBasicBlock::iterator &MI) const;
  /// \returns True if \p MI is atomic cmpxchg operation, false otherwise.
  bool isAtomicCmpxchg(const MachineBasicBlock::iterator &MI) const;
  /// \returns True if \p MI is atomic rmw operation, false otherwise.
  bool isAtomicRmw(const MachineBasicBlock::iterator &MI) const;

  /// \brief Expands atomic fence operation. Returns true if instructions are
  /// added/deleted or \p MI is modified, false otherwise.
  bool expandAtomicFence(MachineBasicBlock::iterator &MI);
  /// \brief Expands atomic load operation. Returns true if instructions are
  /// added/deleted or \p MI is modified, false otherwise.
  bool expandAtomicLoad(MachineBasicBlock::iterator &MI);
  /// \brief Expands atomic store operation. Returns true if instructions are
  /// added/deleted or \p MI is modified, false otherwise.
  bool expandAtomicStore(MachineBasicBlock::iterator &MI);
  /// \brief Expands atomic cmpxchg operation. Returns true if instructions are
  /// added/deleted or \p MI is modified, false otherwise.
  bool expandAtomicCmpxchg(MachineBasicBlock::iterator &MI);
  /// \brief Expands atomic rmw operation. Returns true if instructions are
  /// added/deleted or \p MI is modified, false otherwise.
  bool expandAtomicRmw(MachineBasicBlock::iterator &MI);

public:
  static char ID;

  SIMemoryLegalizer()
      : MachineFunctionPass(ID), TII(nullptr), CTX(nullptr) {}

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  StringRef getPassName() const override {
    return PASS_NAME;
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

} // anonymous namespace

INITIALIZE_PASS(SIMemoryLegalizer, DEBUG_TYPE, PASS_NAME, false, false)

const unsigned SIMemoryLegalizer::Vmcnt0 = 0x7 << 4 | 0xF << 8;
char SIMemoryLegalizer::ID = 0;
char &llvm::SIMemoryLegalizerID = SIMemoryLegalizer::ID;

FunctionPass *llvm::createSIMemoryLegalizerPass() {
  return new SIMemoryLegalizer();
}

bool SIMemoryLegalizer::insertBufferWbinvl1Vol(
    const MachineBasicBlock::iterator &MI) const {
  MachineBasicBlock &MBB = *MI->getParent();
  DebugLoc DL = MI->getDebugLoc();

  BuildMI(MBB, MI, DL, TII->get(AMDGPU::BUFFER_WBINVL1_VOL));
  return true;
}

bool SIMemoryLegalizer::insertWaitcntVmcnt0(
    const MachineBasicBlock::iterator &MI) const {
  MachineBasicBlock &MBB = *MI->getParent();
  DebugLoc DL = MI->getDebugLoc();

  BuildMI(MBB, MI, DL, TII->get(AMDGPU::S_WAITCNT)).addImm(Vmcnt0);
  return true;
}

bool SIMemoryLegalizer::setGLC(const MachineBasicBlock::iterator &MI) const {
  int GLCIdx = AMDGPU::getNamedOperandIdx(MI->getOpcode(), AMDGPU::OpName::glc);
  if (GLCIdx == -1)
    return false;

  MachineOperand &GLC = MI->getOperand(GLCIdx);
  if (GLC.getImm() == 1)
    return false;

  GLC.setImm(1);
  return true;
}

bool SIMemoryLegalizer::removeAtomicPseudoMI() {
  if (AtomicPseudoMI.empty())
    return false;

  for (auto &MI : AtomicPseudoMI)
    MI->eraseFromParent();

  AtomicPseudoMI.clear();
  return true;
}

void SIMemoryLegalizer::reportUnknownSynchScope(
    const MachineBasicBlock::iterator &MI) {
  DiagnosticInfoUnsupported Diag(
      *MI->getParent()->getParent()->getFunction(),
      "Unknown synchronization scope");
  CTX->diagnose(Diag);
}

bool SIMemoryLegalizer::isAtomicFence(
    const MachineBasicBlock::iterator &MI) const {
  return MI->getOpcode() == AMDGPU::ATOMIC_FENCE;
}

bool SIMemoryLegalizer::isAtomicLoad(
    const MachineBasicBlock::iterator &MI) const {
  if (!MI->hasOneMemOperand())
    return false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  return MMO->isAtomic() && MMO->isLoad() && !MMO->isStore() &&
      MMO->getFailureOrdering() == AtomicOrdering::NotAtomic;
}

bool SIMemoryLegalizer::isAtomicStore(
    const MachineBasicBlock::iterator &MI) const {
  if (!MI->hasOneMemOperand())
    return false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  return MMO->isAtomic() && !MMO->isLoad() && MMO->isStore() &&
      MMO->getFailureOrdering() == AtomicOrdering::NotAtomic;
}

bool SIMemoryLegalizer::isAtomicCmpxchg(
    const MachineBasicBlock::iterator &MI) const {
  if (!MI->hasOneMemOperand())
    return false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  return MMO->isAtomic() && MMO->isLoad() && MMO->isStore() &&
      MMO->getFailureOrdering() != AtomicOrdering::NotAtomic;
}

bool SIMemoryLegalizer::isAtomicRmw(
    const MachineBasicBlock::iterator &MI) const {
  if (!MI->hasOneMemOperand())
    return false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  return MMO->isAtomic() && MMO->isLoad() && MMO->isStore() &&
      MMO->getFailureOrdering() == AtomicOrdering::NotAtomic;
}

bool SIMemoryLegalizer::expandAtomicFence(MachineBasicBlock::iterator &MI) {
  assert(isAtomicFence(MI) && "Must be atomic fence");

  bool Changed = false;

  AtomicOrdering Ordering =
      static_cast<AtomicOrdering>(MI->getOperand(0).getImm());
  AMDGPUSynchronizationScope SynchScope =
      static_cast<AMDGPUSynchronizationScope>(MI->getOperand(1).getImm());

  switch (SynchScope) {
  case AMDGPUSynchronizationScope::System:
  case AMDGPUSynchronizationScope::Agent: {
    if (Ordering == AtomicOrdering::Release ||
        Ordering == AtomicOrdering::AcquireRelease ||
        Ordering == AtomicOrdering::SequentiallyConsistent)
      Changed |= insertWaitcntVmcnt0(MI);

    if (Ordering == AtomicOrdering::Acquire ||
        Ordering == AtomicOrdering::AcquireRelease ||
        Ordering == AtomicOrdering::SequentiallyConsistent)
      Changed |= insertBufferWbinvl1Vol(MI);

    break;
  }
  case AMDGPUSynchronizationScope::WorkGroup:
  case AMDGPUSynchronizationScope::Wavefront:
  case AMDGPUSynchronizationScope::Image:
  case AMDGPUSynchronizationScope::SignalHandler: {
    break;
  }
  default: {
    reportUnknownSynchScope(MI);
    break;
  }
  }

  AtomicPseudoMI.push_back(MI);
  return Changed;
}

bool SIMemoryLegalizer::expandAtomicLoad(MachineBasicBlock::iterator &MI) {
  assert(isAtomicLoad(MI) && "Must be atomic load");

  bool Changed = false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  AtomicOrdering Ordering = MMO->getOrdering();
  AMDGPUSynchronizationScope SynchScope =
      static_cast<AMDGPUSynchronizationScope>(MMO->getSynchScope());

  switch (SynchScope) {
  case AMDGPUSynchronizationScope::System:
  case AMDGPUSynchronizationScope::Agent: {
    if (Ordering == AtomicOrdering::Monotonic ||
        Ordering == AtomicOrdering::Acquire ||
        Ordering == AtomicOrdering::SequentiallyConsistent)
      Changed |= setGLC(MI);

    if (Ordering == AtomicOrdering::SequentiallyConsistent)
      Changed |= insertWaitcntVmcnt0(MI);

    if (Ordering == AtomicOrdering::Acquire ||
        Ordering == AtomicOrdering::SequentiallyConsistent) {
      ++MI;
      Changed |= insertWaitcntVmcnt0(MI);
      Changed |= insertBufferWbinvl1Vol(MI);
      --MI;
    }

    break;
  }
  case AMDGPUSynchronizationScope::WorkGroup:
  case AMDGPUSynchronizationScope::Wavefront:
  case AMDGPUSynchronizationScope::Image:
  case AMDGPUSynchronizationScope::SignalHandler: {
    break;
  }
  default: {
    reportUnknownSynchScope(MI);
    break;
  }
  }

  return Changed;
}

bool SIMemoryLegalizer::expandAtomicStore(MachineBasicBlock::iterator &MI) {
  assert(isAtomicStore(MI) && "Must be atomic store");

  bool Changed = false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  AtomicOrdering Ordering = MMO->getOrdering();
  AMDGPUSynchronizationScope SynchScope =
      static_cast<AMDGPUSynchronizationScope>(MMO->getSynchScope());

  switch (SynchScope) {
  case AMDGPUSynchronizationScope::System:
  case AMDGPUSynchronizationScope::Agent: {
    if (Ordering == AtomicOrdering::Release ||
        Ordering == AtomicOrdering::SequentiallyConsistent)
      Changed |= insertWaitcntVmcnt0(MI);

    break;
  }
  case AMDGPUSynchronizationScope::WorkGroup:
  case AMDGPUSynchronizationScope::Wavefront:
  case AMDGPUSynchronizationScope::Image:
  case AMDGPUSynchronizationScope::SignalHandler: {
    break;
  }
  default: {
    reportUnknownSynchScope(MI);
    break;
  }
  }

  return Changed;
}

bool SIMemoryLegalizer::expandAtomicCmpxchg(MachineBasicBlock::iterator &MI) {
  assert(isAtomicCmpxchg(MI) && "Must be atomic cmpxchg");

  bool Changed = false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  AtomicOrdering SuccessOrdering = MMO->getOrdering();
  AtomicOrdering FailureOrdering = MMO->getFailureOrdering();
  AMDGPUSynchronizationScope SynchScope =
      static_cast<AMDGPUSynchronizationScope>(MMO->getSynchScope());

  switch (SynchScope) {
  case AMDGPUSynchronizationScope::System:
  case AMDGPUSynchronizationScope::Agent: {
    Changed |= setGLC(MI);

    if (SuccessOrdering == AtomicOrdering::Release ||
        SuccessOrdering == AtomicOrdering::AcquireRelease ||
        SuccessOrdering == AtomicOrdering::SequentiallyConsistent ||
        FailureOrdering == AtomicOrdering::SequentiallyConsistent)
      Changed |= insertWaitcntVmcnt0(MI);

    if (SuccessOrdering == AtomicOrdering::Acquire ||
        SuccessOrdering == AtomicOrdering::AcquireRelease ||
        SuccessOrdering == AtomicOrdering::SequentiallyConsistent ||
        FailureOrdering == AtomicOrdering::Acquire ||
        FailureOrdering == AtomicOrdering::SequentiallyConsistent) {
      ++MI;
      Changed |= insertWaitcntVmcnt0(MI);
      Changed |= insertBufferWbinvl1Vol(MI);
      --MI;
    }

    break;
  }
  case AMDGPUSynchronizationScope::WorkGroup:
  case AMDGPUSynchronizationScope::Wavefront:
  case AMDGPUSynchronizationScope::Image:
  case AMDGPUSynchronizationScope::SignalHandler: {
    Changed |= setGLC(MI);
    break;
  }
  default: {
    reportUnknownSynchScope(MI);
    break;
  }
  }

  return Changed;
}

bool SIMemoryLegalizer::expandAtomicRmw(MachineBasicBlock::iterator &MI) {
  assert(isAtomicRmw(MI) && "Must be atomic rmw");

  bool Changed = false;

  const MachineMemOperand *MMO = *MI->memoperands_begin();
  AtomicOrdering Ordering = MMO->getOrdering();
  AMDGPUSynchronizationScope SynchScope =
      static_cast<AMDGPUSynchronizationScope>(MMO->getSynchScope());

  switch (SynchScope) {
  case AMDGPUSynchronizationScope::System:
  case AMDGPUSynchronizationScope::Agent: {
    Changed |= setGLC(MI);

    if (Ordering == AtomicOrdering::Release ||
        Ordering == AtomicOrdering::AcquireRelease ||
        Ordering == AtomicOrdering::SequentiallyConsistent)
      Changed |= insertWaitcntVmcnt0(MI);

    if (Ordering == AtomicOrdering::Acquire ||
        Ordering == AtomicOrdering::AcquireRelease ||
        Ordering == AtomicOrdering::SequentiallyConsistent) {
      ++MI;
      Changed |= insertWaitcntVmcnt0(MI);
      Changed |= insertBufferWbinvl1Vol(MI);
      --MI;
    }

    break;
  }
  case AMDGPUSynchronizationScope::WorkGroup:
  case AMDGPUSynchronizationScope::Wavefront:
  case AMDGPUSynchronizationScope::Image:
  case AMDGPUSynchronizationScope::SignalHandler: {
    Changed |= setGLC(MI);
    break;
  }
  default: {
    reportUnknownSynchScope(MI);
    break;
  }
  }

  return Changed;
}

bool SIMemoryLegalizer::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;

  TII = MF.getSubtarget<SISubtarget>().getInstrInfo();
  CTX = &MF.getFunction()->getContext();

  for (auto &MBB : MF) {
    for (auto MI = MBB.begin(); MI != MBB.end(); ++MI) {
      if (isAtomicFence(MI))
        Changed |= expandAtomicFence(MI);
      else if (isAtomicLoad(MI))
        Changed |= expandAtomicLoad(MI);
      else if (isAtomicStore(MI))
        Changed |= expandAtomicStore(MI);
      else if (isAtomicCmpxchg(MI))
        Changed |= expandAtomicCmpxchg(MI);
      else if (isAtomicRmw(MI))
        Changed |= expandAtomicRmw(MI);
    }
  }

  Changed |= removeAtomicPseudoMI();
  return Changed;
}
