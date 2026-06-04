-- ════════════════════════════════════════════════════════════
--  데모(가상) 데이터 일괄 삭제
--  Supabase SQL Editor 에 붙여넣고 RUN.
--  auth.users 를 지우면 profiles·enrollments 가 ON DELETE CASCADE 로 함께 삭제됩니다.
-- ════════════════════════════════════════════════════════════

-- 1) 이번에 넣은 가상 데이터 (이메일이 'demo' 로 시작 — demo_01~29, demoG_05.., demo_probe1)
delete from auth.users where email like 'demo%';

-- 2) (선택) 그동안의 임시 테스트 계정도 함께 정리하려면 주석 해제 후 실행
-- delete from auth.users
-- where email like 'test\_%@example.com' escape '\'
--    or email like 'flow\_%@example.com' escape '\'
--    or email like 'ui\_%@example.com'   escape '\'
--    or email like 'book%@guest.test'
--    or email like 'guest\_%@guest.test' escape '\'
--    or email in ('kim@test.com','hong@example.com','v@test.com');

-- 확인:
-- select count(*) as remaining_demo from auth.users where email like 'demo%';
