; RUN: opt < %s -scalar-evolution -analyze | FileCheck %s

; One side exit dominating the latch, exact backedge taken count is known.
define void @test_01() {

; CHECK-LABEL: Determining loop execution counts for: @test_01
; CHECK-NEXT:  Loop %loop: <multiple exits> backedge-taken count is 50

entry:
  br label %loop

loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %backedge ]
  %side.cond = icmp slt i32 %iv, 50
  br i1 %side.cond, label %backedge, label %side.exit

backedge:
  %iv.next = add i32 %iv, 1
  %loop.cond = icmp slt i32 %iv, 100
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

side.exit:
  ret void
}
