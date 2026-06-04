-- ════════════════════════════════════════════════════════════
--  임시 공개 열람 해제 (anon 읽기 정책 제거 → 다시 관리자만 조회 가능)
--  공개 미리보기 종료 후 RUN. insights.html 에서 PUBLIC_PREVIEW = false 도 함께 설정.
-- ════════════════════════════════════════════════════════════

drop policy if exists "temp public read profiles"    on public.profiles;
drop policy if exists "temp public read enrollments"  on public.enrollments;
drop policy if exists "temp public read coupons"      on public.coupons;
