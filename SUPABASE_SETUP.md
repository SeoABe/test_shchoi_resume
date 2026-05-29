# index.html (강좌 신청) — Supabase 백엔드 연동 가이드

강좌 신청 페이지(`index.html`, 사이트 루트)는 **이중 모드**로 동작합니다.

| 상태 | 동작 |
|---|---|
| Supabase 미설정 (기본) | 데모 모드 — 회원/신청이 브라우저 localStorage에만 저장 |
| Supabase 설정 완료 | 실제 백엔드 — 회원가입·로그인·강좌 신청이 DB에 저장 |

아래 5단계만 따라 하면 실제 백엔드로 전환됩니다. **코드 수정은 1곳(키 2줄)뿐**입니다.

---

## 1. Supabase 프로젝트 생성
1. <https://supabase.com> 가입 → **New project**
2. 프로젝트 이름 / 비밀번호(DB) / 리전(Seoul, ap-northeast-2 권장) 입력 후 생성
3. 1~2분 뒤 프로비저닝 완료

## 2. 데이터베이스 스키마 생성
1. 좌측 메뉴 **SQL Editor** → **New query**
2. 이 저장소의 [`supabase/schema.sql`](supabase/schema.sql) 내용을 전부 붙여넣고 **RUN**
3. `enrollments` 테이블과 RLS 정책이 생성됩니다 (Table Editor에서 확인)

## 3. 인증(Auth) 설정
1. 좌측 메뉴 **Authentication → Sign In / Providers → Email** 활성화 확인
2. **이메일 인증 옵션** (둘 중 택1):
   - **Confirm email 끄기** (`Authentication → Providers → Email → Confirm email` OFF)
     → 가입 즉시 로그인됨. **테스트에 권장.**
   - **Confirm email 켜기 (기본값)**
     → 가입 후 인증 메일 발송. 페이지가 "이메일을 확인해주세요" 안내를 자동 표시합니다.
3. **Site URL / Redirect URLs** 등록 (인증 메일 링크가 돌아올 주소):
   - `Authentication → URL Configuration → Site URL` 에
     `https://seoabe.github.io/test_shchoi_resume/` 입력
   - 로컬 테스트도 하려면 Redirect URLs에 `http://localhost:3000/` 추가

## 4. API 키를 index.html에 입력
1. **Project Settings → API** 에서 두 값 복사:
   - `Project URL`  (예: `https://abcdefgh.supabase.co`)
   - `anon` `public` key  (예: `eyJhbGciOiJIUzI1NiI...`)
2. `index.html` 상단 `<script>` 안의 두 줄을 교체:

```js
const SUPABASE_URL      = 'https://abcdefgh.supabase.co';   // ← Project URL
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiI...';          // ← anon public key
```

> `anon` 키는 **공개되어도 안전한** 클라이언트용 키입니다 (RLS가 데이터를 보호).
> `service_role` 키는 절대 프론트엔드에 넣지 마세요.

## 5. 배포
```bash
git add index.html
git commit -m "Connect index.html to Supabase backend"
git push origin main
```
GitHub Pages 반영 후 회원가입 → 강좌 신청이 실제 DB에 기록됩니다.

---

## 신청 내역 확인 (강사용)
- Supabase 대시보드 **Table Editor → enrollments** 에서 전체 신청 조회
- 또는 SQL Editor:
  ```sql
  select e.created_at, u.email, e.course_name, e.price, e.status
  from enrollments e join auth.users u on u.id = e.user_id
  order by e.created_at desc;
  ```

## 작동 방식 요약
| 동작 | 함수 | Supabase 호출 |
|---|---|---|
| 회원가입 | `doSignup()` | `auth.signUp({ email, password, options:{ data:{ name, phone }}})` |
| 로그인 | `doLogin()` | `auth.signInWithPassword({ email, password })` |
| 로그아웃 | `logout()` | `auth.signOut()` |
| 강좌 신청 | `doEnroll()` | `from('enrollments').insert({...})` |
| 세션 유지 | `refreshNav()` | `auth.getUser()` + `onAuthStateChange` |

---

## 다음 단계 (선택) — 결제 연동
신청 `status`를 `pending → paid`로 바꾸는 결제는 PG사 연동이 필요합니다.

- **국내**: [PortOne(아임포트)](https://portone.io) — 카드·토스·카카오페이 통합, 또는 [토스페이먼츠](https://www.tosspayments.com) 직결
- **해외**: [Stripe](https://stripe.com)
- 결제 검증(웹훅)은 클라이언트가 아니라 **Supabase Edge Function** 또는 별도 서버에서 처리해야 안전합니다.
- 테스트 단계에서는 결제 없이 "신청 접수(`pending`) → 강사가 수동으로 결제 링크 발송" 흐름을 권장합니다.
