//===-- llvm-split: command line tool for testing module splitter ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This program can be used to test the llvm::SplitModule function.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringExtras.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/SplitModule.h"

using namespace llvm;

static cl::opt<std::string>
InputFilename(cl::Positional, cl::desc("<input bitcode file>"),
    cl::init("-"), cl::value_desc("filename"));

static cl::opt<std::string>
OutputFilename("o", cl::desc("Override output filename"),
               cl::value_desc("filename"));

static cl::opt<unsigned> NumOutputs("j", cl::Prefix, cl::init(2),
                                    cl::desc("Number of output files"));

static cl::opt<bool>
    PreserveLocals("preserve-locals", cl::Prefix, cl::init(false),
                   cl::desc("Split without externalizing locals"));

static cl::opt<bool>
    SplitHCCKernels("split-hcc-kernels", cl::Prefix, cl::init(false),
                   cl::desc("Split HCC Kernels and print number of files"));

static cl::opt<unsigned>
    SplitHCCThreshold("split-hcc-threshold", cl::Prefix, cl::init(100),
                   cl::desc("Split HCC Kernels if above kernel count threshold"));

int main(int argc, char **argv) {
  LLVMContext Context;
  SMDiagnostic Err;
  cl::ParseCommandLineOptions(argc, argv, "LLVM module splitter\n");

  std::unique_ptr<Module> M = parseIRFile(InputFilename, Err, Context);

  if (!M) {
    Err.print(argv[0], errs());
    return 1;
  }

  if (SplitHCCKernels) {
    int KernelCount = 0;
    for (auto&& F: M->functions()) {
      if (F.getCallingConv() == CallingConv::AMDGPU_KERNEL)
        KernelCount++;
    }
    outs() << KernelCount << '\n';
    // If below kernel threshold, exit
    // Otherwise we split NumOutputs files
    if (KernelCount <= SplitHCCThreshold)
      return 0;
  }

  unsigned I = 0;
  SplitModule(std::move(M), NumOutputs, [&](std::unique_ptr<Module> MPart) {
    std::error_code EC;
    std::unique_ptr<ToolOutputFile> Out(
        new ToolOutputFile(OutputFilename + utostr(I++), EC, sys::fs::F_None));
    if (EC) {
      errs() << EC.message() << '\n';
      exit(1);
    }

    verifyModule(*MPart);
    WriteBitcodeToFile(MPart.get(), Out->os());

    // Declare success.
    Out->keep();
  }, PreserveLocals);

  return 0;
}
