//===- PtrUseVisitor.cpp - InstVisitors over a pointers uses --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// Implementation of the pointer use visitors.
///
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/PtrUseVisitor.h"

using namespace llvm;

void detail::PtrUseVisitorBase::enqueueUsers(Instruction &I) {
  for (Use &U : I.uses()) {
    if (VisitedUses.insert(&U).second) {
      UseToVisit NewU = {
        UseToVisit::UseAndIsOffsetKnownPair(&U, IsOffsetKnown),
        Offset
      };
      Worklist.push_back(std::move(NewU));
    }
  }
}

bool detail::PtrUseVisitorBase::adjustOffsetForGEP(GetElementPtrInst &GEPI) {
  if (!IsOffsetKnown)
    return false;

  // GEP pointer operand may be address space casted from the original pointer
  // therefore the expected offset size need to match the pointer operand.
  unsigned SZ = Offset.getBitWidth();
  Offset = Offset.zextOrTrunc(DL.getPointerTypeSizeInBits(GEPI.getType()));
  bool Res = GEPI.accumulateConstantOffset(DL, Offset);
  Offset = Offset.zextOrTrunc(SZ);
  return Res;
}
