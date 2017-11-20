//===------ SelectAcceleratorCode.cpp - Select only accelerator code ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares and defines a pass which selects only code which is
// expected to be run by an accelerator i.e. referenced directly or indirectly
// (through a fully inlineable call-chain) by a [[hc]] function. To support
// subsequent processing, it also marks all identified functions as AlwaysInline
// thus making it possible to use only the AlwaysInliner without resorting to a
// more expensive full Inliner pass.
//
//===----------------------------------------------------------------------===//
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Analysis/InlineCost.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include <algorithm>

using namespace llvm;

namespace {
class SelectAcceleratorCode : public ModulePass {
    SmallPtrSet<const Function*, 8u> HCCallees_;

    void findAllHCCallees_(const Function &F, Module &M)
    {
        for (auto&& BB : F) {
            for (auto&& I : BB) {
                if (I.getOpcode() == Instruction::Call) {
                    auto Callee = cast<CallInst>(I).getCalledFunction();
                    if (Callee) {
                        auto Tmp = HCCallees_.insert(Callee->getFunction());
                        if (Tmp.second) findAllHCCallees_(*Callee, M);
                    }
                }
            }
        }
    }

    template<typename T>
    static
    void erase_(T &X)
    {
        X.dropAllReferences();
        X.replaceAllUsesWith(UndefValue::get(X.getType()));
        X.eraseFromParent();
    }

    template<typename F, typename G, typename P>
    bool eraseIf_(F First, G Last, P Predicate) const
    {
        bool erasedSome = false;

        auto It = First();
        while (It != Last()) {
            It->removeDeadConstantUsers();
            if (Predicate(*It)) {
                erase_(*It);
                erasedSome = true;
                It = First();
            }
            else ++It;
        }

        return erasedSome;
    }

    bool eraseNonHCFunctions_(Module &M) const
    {
        return eraseIf_(
            [&]() { return M.begin(); },
            [&]() { return M.end(); },
            [&, this](const Function &F) {
                return HCCallees_.count(F.getFunction()) == 0;
            });
    }

    bool eraseDeadGlobals_(Module &M) const
    {
        return eraseIf_(
            [&]() { return M.global_begin(); },
            [&]() { return M.global_end(); },
            [](const Constant& K) { return !K.isConstantUsed(); });
    }

    bool eraseDeadAliases_(Module &M)
    {
        return eraseIf_(
            [&]() { return M.alias_begin(); },
            [&]() { return M.alias_end(); },
            [](const Constant& K) { return !K.isConstantUsed(); });
    }

    static
    bool alwaysInline_(Function &F)
    {
        if (!F.hasFnAttribute(Attribute::AlwaysInline)) {
            if (F.hasFnAttribute(Attribute::NoInline)) {
                F.removeFnAttr(Attribute::NoInline);
            }
            F.addFnAttr(Attribute::AlwaysInline);

            return false;
        }

        return true;
    }
public:
    static char ID;
    SelectAcceleratorCode() : ModulePass{ID} {}

    bool doInitialization(Module &M) override
    {   // TODO: this may represent a valid analysis pass.
        for (auto&& F : M.functions()) {
            if (F.getCallingConv() == CallingConv::AMDGPU_KERNEL) {
                auto Tmp = HCCallees_.insert(F.getFunction());
                if (Tmp.second) findAllHCCallees_(F, M);
            }
        }

        return false;
    }

    bool runOnModule(Module &M) override
    {
        bool Modified = eraseNonHCFunctions_(M);

        Modified = eraseDeadGlobals_(M) || Modified;

        M.dropTriviallyDeadConstantArrays();

        Modified = eraseDeadAliases_(M) || Modified;

        for (auto&& F : M.functions()) Modified = !alwaysInline_(F) || Modified;

        return Modified;
    }

    bool doFinalization(Module& M) override
    {
        const auto It = std::find_if(M.begin(), M.end(), [](Function& F) {
            return !isInlineViable(F) && !F.isIntrinsic();
        });

        if (It != M.end()) {
            M.getContext().diagnose(DiagnosticInfoUnsupported{
                *It, "The function cannot be inlined."});
        }

        return false;
    }
};
char SelectAcceleratorCode::ID = 0;

static RegisterPass<SelectAcceleratorCode> X{
    "select-accelerator-code",
    "Selects only the code that is expected to run on an accelerator, "
    "ensuring that it can be lowered by AMDGPU.",
    false,
    false};
}