-- ════════════════════════════════════════════════════════════
--  쿠폰 시스템 스키마 (Supabase / PostgreSQL)
--  schema.sql + admin_schema.sql 을 먼저 실행한 뒤, 이 파일을 RUN.
-- ════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────
-- 1) coupons : 쿠폰 (% 할인 / 금액 할인, 사용 횟수 제한)
-- ─────────────────────────────────────────────
create table if not exists public.coupons (
  id             uuid primary key default gen_random_uuid(),
  code           text unique not null,
  discount_type  text not null check (discount_type in ('percent','amount')),
  discount_value integer not null check (discount_value > 0),  -- percent: 1~100, amount: 원
  max_uses       integer not null default 1 check (max_uses > 0),
  used_count     integer not null default 0,
  active         boolean not null default true,
  created_at     timestamptz not null default now()
);

alter table public.coupons enable row level security;

-- 관리자만 직접 접근(목록/발행/수정/삭제). 일반 사용자는 코드 목록을 볼 수 없음(아래 RPC로만 검증)
drop policy if exists "coupons admin all" on public.coupons;
create policy "coupons admin all"
  on public.coupons for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- ─────────────────────────────────────────────
-- 2) enrollments 에 쿠폰/할인 컬럼 추가
--    price = 실제 결제 금액(할인 후), discount = 할인액, coupon_code = 사용 쿠폰
-- ─────────────────────────────────────────────
alter table public.enrollments add column if not exists coupon_code text;
alter table public.enrollments add column if not exists discount integer not null default 0;


-- ─────────────────────────────────────────────
-- 3) 쿠폰 검증 RPC (읽기 전용) — 전체 코드 노출 없이 단건 확인
-- ─────────────────────────────────────────────
create or replace function public.validate_coupon(p_code text)
returns table(code text, discount_type text, discount_value int, remaining int)
language sql security definer stable
set search_path = public
as $$
  select code, discount_type, discount_value, (max_uses - used_count) as remaining
  from public.coupons
  where upper(code) = upper(trim(p_code))
    and active
    and used_count < max_uses;
$$;

-- ─────────────────────────────────────────────
-- 4) 쿠폰 사용 RPC (원자적 차감) — 동시 사용에도 초과 차감 방지
--    반환: 남은 횟수(>=0). 사용 불가/소진 시 -1.
-- ─────────────────────────────────────────────
create or replace function public.redeem_coupon(p_code text)
returns integer
language plpgsql security definer
set search_path = public
as $$
declare r integer;
begin
  update public.coupons
     set used_count = used_count + 1
   where upper(code) = upper(trim(p_code))
     and active
     and used_count < max_uses
   returning (max_uses - used_count) into r;

  if r is null then
    return -1;   -- 없음 / 비활성 / 소진
  end if;
  return r;
end;
$$;

grant execute on function public.validate_coupon(text) to anon, authenticated;
grant execute on function public.redeem_coupon(text)   to anon, authenticated;

-- (잔여량은 관리자 화면의 "새로고침" 버튼으로 다시 불러옵니다 — 별도 Realtime 설정 불필요)


-- ════════════════════════════════════════════════════════════
--  (선택) 예시 고정 쿠폰 — 필요 시 주석 해제하여 실행
-- ════════════════════════════════════════════════════════════
-- insert into public.coupons (code, discount_type, discount_value, max_uses) values
--   ('50%',      'percent', 50,    100),
--   ('30%',      'percent', 30,    100),
--   ('50000WON', 'amount',  50000, 50)
-- on conflict (code) do nothing;
