//=== UndefineGlobalsInAcceleratorCode.cpp - Make globals undefined extern ===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares and defines a pass which turns all mutable GlobalVariables
// in code compiled for an accelerator into declarations with external weak
// linkage. They will be defined and bound to a pinned host side allocation by
// the HC RT. This enables seamless support for all types of objects with static
// (and thread) storage duration.
// TODO: technically, constants should not be ignored, as this breaks identity
//       of address; once we no longer have to use the pinning kludge, which
//       breaks it anyway, we should do the same thing indiscriminately for all
//       GlobalVariables.
// TODO: handle dso_locals in a way that makes them useful on dGPU.
//===----------------------------------------------------------------------===//
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"

using namespace llvm;

namespace {
class UndefineGlobalsInAcceleratorCode : public ModulePass {
    // TODO: this is an imperfect way of dealing with tile_static, which shall
    //       break if we switch address space mapping. In general, tile_static
    //       should be a proper storage duration that is essentially a subset of
    //       thread_local, and can be queried just like the latter.
    static constexpr unsigned int LocalAddressSpace{3};
public:
    static char ID;
    UndefineGlobalsInAcceleratorCode() : ModulePass{ID} {}

    bool runOnModule(Module &M) override
    {
        bool Modified{false};

        for (auto &&Global : M.globals()) {
            if (!isa<GlobalVariable>(Global)) continue;

            auto& GV = cast<GlobalVariable>(Global);

            if (GV.isConstant()) continue;
            if (GV.getAddressSpace() == LocalAddressSpace) continue;
            if (GV.isDSOLocal()) continue;

            GV.setExternallyInitialized(true);
            GV.setInitializer(nullptr);
            GV.setLinkage(GlobalValue::LinkageTypes::ExternalWeakLinkage);

            Modified = true;
        }

        return Modified;
    }
};
char UndefineGlobalsInAcceleratorCode::ID = 0;

static RegisterPass<UndefineGlobalsInAcceleratorCode> X{
    "undefine-globals-in-accelerator-code",
    "Makes non-constant globals undefined with external linkage, in code "
    "expected to run on an accelerator; the undefined symbols are resolved by "
    "the HC RT, when creating a executable using the resulting code object.",
    false,
    false};
}
