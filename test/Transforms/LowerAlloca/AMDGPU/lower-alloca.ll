; RUN: opt < %s -S -lower-alloca -infer-address-spaces | FileCheck %s

target triple = "amdgcn-amd-amdhsa"

define  void @kernel() {
; LABEL: @lower_alloca
  %A = alloca i32
; CHECK: addrspacecast i32* %A to i32 addrspace(5)*
; CHECK: store i32 0, i32 addrspace(5)* {{%.+}}
  store i32 0, i32* %A
  call void @callee(i32* %A)
  ret void
}
declare void @callee(i32*)
