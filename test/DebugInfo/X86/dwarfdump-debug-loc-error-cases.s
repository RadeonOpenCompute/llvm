# RUN: llvm-mc %s -filetype obj -triple x86_64-pc-linux --defsym CASE1=0 -o %t1.o
# RUN: llvm-dwarfdump -debug-loc %t1.o 2>&1 | FileCheck %s

# RUN: llvm-mc %s -filetype obj -triple x86_64-pc-linux --defsym CASE2=0 -o %t2.o
# RUN: llvm-dwarfdump -debug-loc %t2.o 2>&1 | FileCheck %s

# RUN: llvm-mc %s -filetype obj -triple x86_64-pc-linux --defsym CASE3=0 -o %t3.o
# RUN: llvm-dwarfdump -debug-loc %t3.o 2>&1 | FileCheck %s

# RUN: llvm-mc %s -filetype obj -triple x86_64-pc-linux --defsym CASE4=0 -o %t4.o
# RUN: llvm-dwarfdump -debug-loc %t4.o 2>&1 | FileCheck %s

# RUN: llvm-mc %s -filetype obj -triple x86_64-pc-linux --defsym CASE5=0 -o %t5.o
# RUN: llvm-dwarfdump -debug-loc %t5.o 2>&1 | FileCheck %s

# RUN: llvm-mc %s -filetype obj -triple x86_64-pc-linux --defsym CASE6=0 -o %t6.o
# RUN: llvm-dwarfdump -debug-loc %t6.o 2>&1 | FileCheck %s

# CHECK: error: unexpected end of data

.section  .debug_loc,"",@progbits
.ifdef CASE1
  .byte  1                       # bogus
.endif
.ifdef CASE2
  .long  0                       # starting offset
.endif
.ifdef CASE3
  .long  0                       # starting offset
  .long  1                       # ending offset
.endif
.ifdef CASE4
  .long  0                       # starting offset
  .long  1                       # ending offset
  .word  0                       # Loc expr size
.endif
.ifdef CASE5
  .long  0                       # starting offset
  .long  1                       # ending offset
  .word  0                       # Loc expr size
  .long  0                       # starting offset
.endif
.ifdef CASE6
  .long  0                       # starting offset
  .long  1                       # ending offset
  .word  0xffff                  # Loc expr size
.endif

# A minimal compile unit is needed to deduce the address size of the location
# lists
.section  .debug_info,"",@progbits
  .long  .Lcu_end0-.Lcu_begin0   # Length of Unit
.Lcu_begin0:
  .short  4                      # DWARF version number
  .long  0                       # Offset Into Abbrev. Section
  .byte  8                       # Address Size (in bytes)
  .byte  0                       # End Of Children Mark
.Lcu_end0:
