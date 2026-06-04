-- ════════════════════════════════════════════════════════════
--  ⚠️ 임시: 로그인 없이 인사이트 페이지 열람 허용
--  (anon 역할이 profiles/enrollments/coupons 를 읽을 수 있게 함)
--  Supabase SQL Editor 에 붙여넣고 RUN.
--
--  ※ 주의: 이 정책이 켜져 있으면 anon 키만으로 회원 데이터(이메일 등)를
--    조회할 수 있습니다. 공개 미리보기가 끝나면 반드시
--    insights_public_disable.sql 을 실행해 되돌리세요.
-- ════════════════════════════════════════════════════════════

drop policy if exists "temp public read profiles"    on public.profiles;
drop policy if exists "temp public read enrollments"  on public.enrollments;
drop policy if exists "temp public read coupons"      on public.coupons;

create policy "temp public read profiles"   on public.profiles    for select to anon using (true);
create policy "temp public read enrollments" on public.enrollments for select to anon using (true);
create policy "temp public read coupons"    on public.coupons     for select to anon using (true);
