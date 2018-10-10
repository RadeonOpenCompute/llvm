add_llvm_loadable_module(
    LLVMUndefineGlobalsInAcceleratorCode
    UndefineGlobalsInAcceleratorCode.cpp)

add_dependencies(LLVMUndefineGlobalsInAcceleratorCode intrinsics_gen)
