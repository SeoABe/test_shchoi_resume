-- ════════════════════════════════════════════════════════════
--  course.html 백엔드 스키마 (Supabase / PostgreSQL)
--  Supabase 대시보드 → SQL Editor 에 붙여넣고 RUN 하세요.
-- ════════════════════════════════════════════════════════════

-- 1) 강좌 신청 테이블 ------------------------------------------------
create table if not exists public.enrollments (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  course_key  text not null,                 -- basic / proposal / claudecode / enterprise
  course_name text not null,
  price       integer not null default 0,    -- 원 단위 (0 = 견적 문의)
  status      text not null default 'pending',-- pending / paid / cancelled
  created_at  timestamptz not null default now()
);

-- 조회 성능용 인덱스
create index if not exists enrollments_user_id_idx on public.enrollments(user_id);
create index if not exists enrollments_created_idx  on public.enrollments(created_at desc);

-- 2) Row Level Security (본인 데이터만 접근) -------------------------
alter table public.enrollments enable row level security;

-- 로그인 사용자가 "자기 자신의" 신청만 추가 가능
drop policy if exists "insert own enrollments" on public.enrollments;
create policy "insert own enrollments"
  on public.enrollments for insert
  to authenticated
  with check (auth.uid() = user_id);

-- 로그인 사용자가 "자기 자신의" 신청만 조회 가능
drop policy if exists "select own enrollments" on public.enrollments;
create policy "select own enrollments"
  on public.enrollments for select
  to authenticated
  using (auth.uid() = user_id);

-- (선택) 사용자가 본인 신청을 취소(상태 변경)할 수 있게 하려면:
-- drop policy if exists "update own enrollments" on public.enrollments;
-- create policy "update own enrollments"
--   on public.enrollments for update
--   to authenticated
--   using (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════
--  참고: 강사(관리자)가 전체 신청 내역을 보려면 Supabase 대시보드의
--  Table Editor / SQL Editor 에서 service_role 권한으로 조회하면 됩니다.
--  (RLS는 anon/authenticated 키에만 적용되고 service_role은 우회합니다.)
-- ════════════════════════════════════════════════════════════
