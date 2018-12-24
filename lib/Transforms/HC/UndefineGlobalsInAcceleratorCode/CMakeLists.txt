add_llvm_library(
    LLVMUndefineGlobalsInAcceleratorCode
        MODULE
        UndefineGlobalsInAcceleratorCode.cpp)

add_dependencies(LLVMUndefineGlobalsInAcceleratorCode intrinsics_gen)