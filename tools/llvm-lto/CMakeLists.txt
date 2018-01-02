set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  BitReader
  BitWriter
  Core
  IRReader
  LTO
  MC
  Object
  Support
  Target
  )

# Support plugins.
set(LLVM_NO_DEAD_STRIP 1)

add_llvm_tool(llvm-lto
  llvm-lto.cpp

  DEPENDS
  intrinsics_gen
  )
export_executable_symbols(llvm-lto)
