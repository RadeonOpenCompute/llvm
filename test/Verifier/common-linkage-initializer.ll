; REQUIRES: asserts
; RUN: llvm-as < %s -o /dev/null 2>&1
;
; Test the IR verifier does not assert when a global variable with common linkage
; has an initializer which is not zeroinitializer.
;
; In C99 tentative definition of file-scope variable results in common linkage,
; e.g.
;   private char *p;
;   private char *p;
; which are initialized by default initializer. For pointer type global variable,
; the default initializer is null pointer, which does not necessarily have zero
; value. If a structure contains pointer type member for which null pointer does
; not have zero value, the strucutre cannot be initialized with zeroinitializer.
 
target datalayout = "e-p:32:32-p1:64:64-p2:64:64-p3:32:32-p4:64:64-p5:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64"
target triple = "amdgcn"

%struct.ST = type <{ i8*, i8 addrspace(1)*, i8 addrspace(2)*, i8 addrspace(3)*, i8 addrspace(4)* }>

@st = common addrspace(1) global %struct.ST <{ i8* addrspacecast (i8 addrspace(4)* null to i8*), i8 addrspace(1)* null, i8 addrspace(2)* null, i8 addrspace(3)* addrspacecast (i8 addrspace(4)* null to i8 addrspace(3)*), i8 addrspace(4)* null }>, align 4
