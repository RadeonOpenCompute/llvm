; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s --check-prefix=X64

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @test(i256* %a, i256* %b, i256* %out) #0 {
; X32-LABEL: test:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    pushl %ebx
; X32-NEXT:    .cfi_def_cfa_offset 12
; X32-NEXT:    pushl %edi
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    pushl %esi
; X32-NEXT:    .cfi_def_cfa_offset 20
; X32-NEXT:    subl $88, %esp
; X32-NEXT:    .cfi_def_cfa_offset 108
; X32-NEXT:    .cfi_offset %esi, -20
; X32-NEXT:    .cfi_offset %edi, -16
; X32-NEXT:    .cfi_offset %ebx, -12
; X32-NEXT:    .cfi_offset %ebp, -8
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl 12(%ecx), %ebp
; X32-NEXT:    movl 8(%ecx), %edi
; X32-NEXT:    movl %edi, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl (%eax), %ebx
; X32-NEXT:    movl %ebx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %edi, %eax
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %edx, %ecx
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    movl %ebp, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %edx, %esi
; X32-NEXT:    movl %eax, %ebx
; X32-NEXT:    addl %ecx, %ebx
; X32-NEXT:    adcl $0, %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl 4(%eax), %ecx
; X32-NEXT:    movl %edi, %eax
; X32-NEXT:    mull %ecx
; X32-NEXT:    movl %ecx, %edi
; X32-NEXT:    movl %edi, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %edx, %ecx
; X32-NEXT:    addl %ebx, %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl %esi, %ecx
; X32-NEXT:    setb {{[0-9]+}}(%esp) # 1-byte Folded Spill
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    mull %edi
; X32-NEXT:    movl %edx, %ebx
; X32-NEXT:    movl %eax, %edi
; X32-NEXT:    addl %ecx, %edi
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax # 1-byte Folded Reload
; X32-NEXT:    adcl %eax, %ebx
; X32-NEXT:    xorl %edx, %edx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    movl %ecx, %eax
; X32-NEXT:    mull %edx
; X32-NEXT:    movl %edx, %ebp
; X32-NEXT:    movl %ebp, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %eax, %esi
; X32-NEXT:    movl %esi, (%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    xorl %edx, %edx
; X32-NEXT:    mull %edx
; X32-NEXT:    movl %edx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    addl %esi, %eax
; X32-NEXT:    adcl %ebp, %edx
; X32-NEXT:    addl %edi, %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl %ebx, %edx
; X32-NEXT:    movl %edx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movl (%esi), %ebp
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    movl %ebp, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    mull %ecx
; X32-NEXT:    movl %ecx, %edi
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %edx, %ecx
; X32-NEXT:    movl 4(%esi), %esi
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    movl %esi, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    mull %edi
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    movl %eax, %ebx
; X32-NEXT:    addl %ecx, %ebx
; X32-NEXT:    adcl $0, %edi
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebp # 4-byte Reload
; X32-NEXT:    mull %ebp
; X32-NEXT:    movl %edx, %ecx
; X32-NEXT:    addl %ebx, %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl %edi, %ecx
; X32-NEXT:    setb %bl
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    mull %ebp
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    movl %eax, %ebp
; X32-NEXT:    addl %ecx, %ebp
; X32-NEXT:    movzbl %bl, %eax
; X32-NEXT:    adcl %eax, %edi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi # 4-byte Reload
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    xorl %edx, %edx
; X32-NEXT:    mull %edx
; X32-NEXT:    movl %edx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl (%esp), %ecx # 4-byte Reload
; X32-NEXT:    addl %eax, %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    adcl %edx, %eax
; X32-NEXT:    addl %ebp, %ecx
; X32-NEXT:    adcl %edi, %eax
; X32-NEXT:    addl {{[0-9]+}}(%esp), %ecx # 4-byte Folded Reload
; X32-NEXT:    movl %ecx, (%esp) # 4-byte Spill
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl $0, {{[0-9]+}}(%esp) # 4-byte Folded Spill
; X32-NEXT:    adcl $0, {{[0-9]+}}(%esp) # 4-byte Folded Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl %eax, %ecx
; X32-NEXT:    movl 8(%ecx), %ebx
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    movl %esi, %edi
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %edx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %edx, %ebp
; X32-NEXT:    movl %eax, %esi
; X32-NEXT:    addl {{[0-9]+}}(%esp), %esi # 4-byte Folded Reload
; X32-NEXT:    adcl $0, %ebp
; X32-NEXT:    movl 12(%ecx), %ecx
; X32-NEXT:    movl %edi, %eax
; X32-NEXT:    mull %ecx
; X32-NEXT:    movl %ecx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    addl %esi, %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl %ebp, %edi
; X32-NEXT:    setb {{[0-9]+}}(%esp) # 1-byte Folded Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    mull %ecx
; X32-NEXT:    movl %edx, %esi
; X32-NEXT:    movl %eax, %ebp
; X32-NEXT:    addl %edi, %ebp
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax # 1-byte Folded Reload
; X32-NEXT:    adcl %eax, %esi
; X32-NEXT:    movl %ebx, %edi
; X32-NEXT:    movl %edi, %eax
; X32-NEXT:    xorl %ecx, %ecx
; X32-NEXT:    mull %ecx
; X32-NEXT:    movl %edx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx # 4-byte Reload
; X32-NEXT:    addl %eax, %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    adcl %edx, %eax
; X32-NEXT:    addl %ebp, %ebx
; X32-NEXT:    adcl %esi, %eax
; X32-NEXT:    movl (%esp), %ecx # 4-byte Reload
; X32-NEXT:    addl %ecx, {{[0-9]+}}(%esp) # 4-byte Folded Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    adcl %ecx, {{[0-9]+}}(%esp) # 4-byte Folded Spill
; X32-NEXT:    adcl $0, %ebx
; X32-NEXT:    adcl $0, %eax
; X32-NEXT:    addl {{[0-9]+}}(%esp), %ebx # 4-byte Folded Reload
; X32-NEXT:    movl %ebx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    setb (%esp) # 1-byte Folded Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi # 4-byte Reload
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    movl %edi, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    mull %edi
; X32-NEXT:    movl %edx, %ebx
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    movl %ecx, %eax
; X32-NEXT:    mull %edi
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    movl %eax, %ebp
; X32-NEXT:    addl %ebx, %ebp
; X32-NEXT:    adcl $0, %edi
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx # 4-byte Reload
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %edx, %esi
; X32-NEXT:    addl %ebp, %eax
; X32-NEXT:    movl %eax, %ebp
; X32-NEXT:    adcl %edi, %esi
; X32-NEXT:    setb {{[0-9]+}}(%esp) # 1-byte Folded Spill
; X32-NEXT:    movl %ecx, %eax
; X32-NEXT:    mull %ebx
; X32-NEXT:    addl %esi, %eax
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %esi # 1-byte Folded Reload
; X32-NEXT:    adcl %esi, %edx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi # 4-byte Reload
; X32-NEXT:    addl {{[0-9]+}}(%esp), %esi # 4-byte Folded Reload
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %ecx # 4-byte Folded Reload
; X32-NEXT:    addl %eax, %esi
; X32-NEXT:    adcl %edx, %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    addl %eax, {{[0-9]+}}(%esp) # 4-byte Folded Spill
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %ebp # 4-byte Folded Reload
; X32-NEXT:    movl %ebp, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movzbl (%esp), %eax # 1-byte Folded Reload
; X32-NEXT:    adcl %eax, %esi
; X32-NEXT:    movl %esi, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl $0, %ecx
; X32-NEXT:    movl %ecx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl 16(%ecx), %esi
; X32-NEXT:    imull %esi, %ebx
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi # 4-byte Reload
; X32-NEXT:    mull %edi
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    addl %ebx, %edx
; X32-NEXT:    movl 20(%ecx), %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    imull %eax, %edi
; X32-NEXT:    addl %edx, %edi
; X32-NEXT:    movl %edi, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl 24(%ecx), %eax
; X32-NEXT:    movl %ecx, %ebp
; X32-NEXT:    movl %eax, %edi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    imull %ecx, %edi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx # 4-byte Reload
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X32-NEXT:    addl %edi, %edx
; X32-NEXT:    movl 28(%ebp), %ebp
; X32-NEXT:    imull %ebx, %ebp
; X32-NEXT:    addl %edx, %ebp
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edx # 4-byte Reload
; X32-NEXT:    addl %edx, (%esp) # 4-byte Folded Spill
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %ebp # 4-byte Folded Reload
; X32-NEXT:    movl %ebx, %eax
; X32-NEXT:    mull %esi
; X32-NEXT:    movl %edx, %ebx
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %ecx, %eax
; X32-NEXT:    mull %esi
; X32-NEXT:    movl %edx, %ecx
; X32-NEXT:    movl %eax, %edi
; X32-NEXT:    addl %ebx, %edi
; X32-NEXT:    adcl $0, %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx # 4-byte Reload
; X32-NEXT:    mull %ebx
; X32-NEXT:    movl %edx, %esi
; X32-NEXT:    addl %edi, %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl %ecx, %esi
; X32-NEXT:    setb %cl
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    mull %ebx
; X32-NEXT:    addl %esi, %eax
; X32-NEXT:    movzbl %cl, %ecx
; X32-NEXT:    adcl %ecx, %edx
; X32-NEXT:    addl (%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X32-NEXT:    adcl %ebp, %edx
; X32-NEXT:    movl %edx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X32-NEXT:    movl 28(%ebx), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi # 4-byte Reload
; X32-NEXT:    imull %esi, %ecx
; X32-NEXT:    movl 24(%ebx), %edi
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    mull %edi
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    addl %ecx, %edx
; X32-NEXT:    imull {{[0-9]+}}(%esp), %edi # 4-byte Folded Reload
; X32-NEXT:    addl %edx, %edi
; X32-NEXT:    movl 16(%ebx), %ebp
; X32-NEXT:    movl 20(%ebx), %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    movl %eax, %ecx
; X32-NEXT:    imull %ebx, %ecx
; X32-NEXT:    movl %ebx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    mull %ebp
; X32-NEXT:    addl %ecx, %edx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    imull %ebp, %ecx
; X32-NEXT:    addl %edx, %ecx
; X32-NEXT:    addl {{[0-9]+}}(%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    adcl %edi, %ecx
; X32-NEXT:    movl %ecx, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    mull %esi
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp) # 4-byte Spill
; X32-NEXT:    movl %ebx, %eax
; X32-NEXT:    mull %esi
; X32-NEXT:    movl %edx, %ecx
; X32-NEXT:    movl %eax, %ebx
; X32-NEXT:    addl %edi, %ebx
; X32-NEXT:    adcl $0, %ecx
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebp # 4-byte Reload
; X32-NEXT:    mull %ebp
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    movl %eax, %esi
; X32-NEXT:    addl %ebx, %esi
; X32-NEXT:    adcl %ecx, %edi
; X32-NEXT:    setb %cl
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax # 4-byte Reload
; X32-NEXT:    mull %ebp
; X32-NEXT:    addl %edi, %eax
; X32-NEXT:    movzbl %cl, %ecx
; X32-NEXT:    adcl %ecx, %edx
; X32-NEXT:    addl {{[0-9]+}}(%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %edx # 4-byte Folded Reload
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx # 4-byte Reload
; X32-NEXT:    addl {{[0-9]+}}(%esp), %ecx # 4-byte Folded Reload
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %esi # 4-byte Folded Reload
; X32-NEXT:    adcl (%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %edx # 4-byte Folded Reload
; X32-NEXT:    addl {{[0-9]+}}(%esp), %ecx # 4-byte Folded Reload
; X32-NEXT:    movl %ecx, %ebx
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %esi # 4-byte Folded Reload
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %eax # 4-byte Folded Reload
; X32-NEXT:    adcl {{[0-9]+}}(%esp), %edx # 4-byte Folded Reload
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi # 4-byte Reload
; X32-NEXT:    movl %edi, (%ecx)
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi # 4-byte Reload
; X32-NEXT:    movl %edi, 4(%ecx)
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi # 4-byte Reload
; X32-NEXT:    movl %edi, 8(%ecx)
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi # 4-byte Reload
; X32-NEXT:    movl %edi, 12(%ecx)
; X32-NEXT:    movl %ebx, 16(%ecx)
; X32-NEXT:    movl %esi, 20(%ecx)
; X32-NEXT:    movl %eax, 24(%ecx)
; X32-NEXT:    movl %edx, 28(%ecx)
; X32-NEXT:    addl $88, %esp
; X32-NEXT:    popl %esi
; X32-NEXT:    popl %edi
; X32-NEXT:    popl %ebx
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: test:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %r15
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    pushq %r14
; X64-NEXT:    .cfi_def_cfa_offset 24
; X64-NEXT:    pushq %rbx
; X64-NEXT:    .cfi_def_cfa_offset 32
; X64-NEXT:    .cfi_offset %rbx, -32
; X64-NEXT:    .cfi_offset %r14, -24
; X64-NEXT:    .cfi_offset %r15, -16
; X64-NEXT:    movq %rdx, %r9
; X64-NEXT:    movq (%rdi), %r11
; X64-NEXT:    movq 8(%rdi), %r8
; X64-NEXT:    movq 16(%rdi), %rbx
; X64-NEXT:    movq 16(%rsi), %r10
; X64-NEXT:    movq (%rsi), %rcx
; X64-NEXT:    movq 8(%rsi), %r15
; X64-NEXT:    movq 24(%rdi), %rdi
; X64-NEXT:    imulq %rcx, %rdi
; X64-NEXT:    movq %rcx, %rax
; X64-NEXT:    mulq %rbx
; X64-NEXT:    movq %rax, %r14
; X64-NEXT:    addq %rdi, %rdx
; X64-NEXT:    imulq %r15, %rbx
; X64-NEXT:    addq %rdx, %rbx
; X64-NEXT:    movq %r10, %rdi
; X64-NEXT:    imulq %r8, %rdi
; X64-NEXT:    movq %r10, %rax
; X64-NEXT:    mulq %r11
; X64-NEXT:    movq %rax, %r10
; X64-NEXT:    addq %rdi, %rdx
; X64-NEXT:    movq 24(%rsi), %rdi
; X64-NEXT:    imulq %r11, %rdi
; X64-NEXT:    addq %rdx, %rdi
; X64-NEXT:    addq %r14, %r10
; X64-NEXT:    adcq %rbx, %rdi
; X64-NEXT:    movq %r11, %rax
; X64-NEXT:    mulq %rcx
; X64-NEXT:    movq %rdx, %rsi
; X64-NEXT:    movq %rax, %r14
; X64-NEXT:    movq %r8, %rax
; X64-NEXT:    mulq %rcx
; X64-NEXT:    movq %rdx, %rcx
; X64-NEXT:    movq %rax, %rbx
; X64-NEXT:    addq %rsi, %rbx
; X64-NEXT:    adcq $0, %rcx
; X64-NEXT:    movq %r11, %rax
; X64-NEXT:    mulq %r15
; X64-NEXT:    movq %rdx, %rsi
; X64-NEXT:    movq %rax, %r11
; X64-NEXT:    addq %rbx, %r11
; X64-NEXT:    adcq %rcx, %rsi
; X64-NEXT:    setb %al
; X64-NEXT:    movzbl %al, %ecx
; X64-NEXT:    movq %r8, %rax
; X64-NEXT:    mulq %r15
; X64-NEXT:    addq %rsi, %rax
; X64-NEXT:    adcq %rcx, %rdx
; X64-NEXT:    addq %r10, %rax
; X64-NEXT:    adcq %rdi, %rdx
; X64-NEXT:    movq %r14, (%r9)
; X64-NEXT:    movq %r11, 8(%r9)
; X64-NEXT:    movq %rax, 16(%r9)
; X64-NEXT:    movq %rdx, 24(%r9)
; X64-NEXT:    popq %rbx
; X64-NEXT:    popq %r14
; X64-NEXT:    popq %r15
; X64-NEXT:    retq
entry:
  %av = load i256, i256* %a
  %bv = load i256, i256* %b
  %r = mul i256 %av, %bv
  store i256 %r, i256* %out
  ret void
}

attributes #0 = { norecurse nounwind uwtable }
