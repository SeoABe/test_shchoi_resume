-- ════════════════════════════════════════════════════════════
--  관리자 페이지 + 뉴스레터 스키마 (Supabase / PostgreSQL)
--  schema.sql(enrollments) 을 먼저 실행한 뒤, 이 파일을 SQL Editor 에 붙여넣고 RUN.
-- ════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────
-- 1) profiles : 회원 프로필 (auth.users 미러 + 뉴스레터 동의/관리자 플래그)
-- ─────────────────────────────────────────────
create table if not exists public.profiles (
  id                uuid primary key references auth.users(id) on delete cascade,
  email             text,
  name              text,
  phone             text,
  newsletter_opt_in boolean not null default false,
  is_admin          boolean not null default false,
  created_at        timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- 관리자 여부 판별 함수 (security definer → RLS 재귀 회피)
create or replace function public.is_admin()
returns boolean
language sql security definer stable
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and is_admin);
$$;

-- profiles 정책
drop policy if exists "profiles read own"      on public.profiles;
drop policy if exists "profiles update own"    on public.profiles;
drop policy if exists "profiles admin read all" on public.profiles;

create policy "profiles read own"
  on public.profiles for select to authenticated
  using (id = auth.uid());

create policy "profiles update own"
  on public.profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy "profiles admin read all"
  on public.profiles for select to authenticated
  using (public.is_admin());

-- 신규 가입 시 프로필 자동 생성 (auth.users 메타데이터 복사)
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, phone, newsletter_opt_in)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.raw_user_meta_data->>'phone', ''),
    coalesce((new.raw_user_meta_data->>'newsletter_opt_in')::boolean, false)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 기존 가입자(트리거 적용 전) 백필
insert into public.profiles (id, email, name, phone, newsletter_opt_in)
select
  id, email,
  coalesce(raw_user_meta_data->>'name', ''),
  coalesce(raw_user_meta_data->>'phone', ''),
  coalesce((raw_user_meta_data->>'newsletter_opt_in')::boolean, false)
from auth.users
on conflict (id) do nothing;


-- ─────────────────────────────────────────────
-- 2) enrollments 에 관리자 전체 조회 정책 추가
-- ─────────────────────────────────────────────
drop policy if exists "enroll admin read all" on public.enrollments;
create policy "enroll admin read all"
  on public.enrollments for select to authenticated
  using (public.is_admin());

-- (선택) 관리자가 신청 상태(pending→paid 등)를 변경할 수 있게:
drop policy if exists "enroll admin update" on public.enrollments;
create policy "enroll admin update"
  on public.enrollments for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- ─────────────────────────────────────────────
-- 3) newsletters : 뉴스레터 발행 기록
-- ─────────────────────────────────────────────
create table if not exists public.newsletters (
  id              uuid primary key default gen_random_uuid(),
  subject         text not null,
  body            text not null,
  status          text not null default 'draft',   -- draft / sent
  recipient_count integer not null default 0,
  created_at      timestamptz not null default now(),
  sent_at         timestamptz
);

alter table public.newsletters enable row level security;

-- 관리자만 전체 권한
drop policy if exists "newsletter admin all" on public.newsletters;
create policy "newsletter admin all"
  on public.newsletters for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- ════════════════════════════════════════════════════════════
--  4) ⭐ 본인 계정을 관리자로 지정 (이메일을 본인 것으로 변경!)
--     먼저 해당 이메일로 회원가입을 1회 완료한 뒤 실행하세요.
-- ════════════════════════════════════════════════════════════
update public.profiles set is_admin = true
where email = 'typeholic@gmail.com';   -- ← 관리자로 만들 이메일

-- 확인:
-- select email, is_admin, newsletter_opt_in from public.profiles order by created_at desc;
