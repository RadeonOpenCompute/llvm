; RUN: llc -march=amdgcn -mcpu=gfx900 -print-after=si-annotate-control-flow %s -o /dev/null 2>&1 | FileCheck %s

target triple = "amdgcn--"

define amdgpu_kernel void @switch_unreachable_default(i32* %out, i8* %in0, i8* %in1) #0 {
centry:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  switch i32 %tid, label %sw.default [
    i32 0, label %sw.bb0
    i32 1, label %sw.bb1
  ]

sw.bb0:
  br label %sw.epilog

sw.bb1:
  br label %sw.epilog

sw.default:
  unreachable

sw.epilog:
  %ptr = phi i8* [%in0, %sw.bb0], [%in1, %sw.bb1]
  %gep_in = getelementptr inbounds i8, i8* %ptr, i64 0
  br label %sw.while

; CHECK: load i8
; CHECK-NOT: {{ br }}
; CHECK: icmp eq
; CHECK-NOT: {{ br }}
; CHECK: @llvm.amdgcn.if

sw.while:
  %p = phi i8* [ %gep_in, %sw.epilog ], [ %incdec.ptr, %sw.while ]
  %count = phi i32 [ 0, %sw.epilog ], [ %count.inc, %sw.while ]
  %char = load i8, i8* %p, align 1
  %tobool = icmp eq i8 %char, 0
  %incdec.ptr = getelementptr inbounds i8, i8* %p, i64 1
  %count.inc = add i32 %count, 1
  br i1 %tobool, label %sw.exit, label %sw.while

sw.exit:
  %tid64 = zext i32 %tid to i64
  %gep_out = getelementptr inbounds i32, i32* %out, i64 %tid64
  store i32 %count, i32* %gep_out, align 4
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #0

attributes #0 = { nounwind readnone }
attributes #1 = { convergent noinline optnone }
