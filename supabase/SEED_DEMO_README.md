# 가상(데모) 데이터 안내

인사이트 페이지(`insights.html`)와 관리자 대시보드 확인용으로 **가상 데이터 ~30건**을 실제 Supabase DB에 입력했습니다.

## 입력 내역
- **회원 30명** (`profiles` + `auth.users`) — 가입일을 최근 약 28일에 걸쳐 분산
- **구매 29건** (`enrollments`) — 강좌·도서 혼합, 일부 쿠폰 적용, 재구매·미구매 포함
- 원본 데이터: [`seed_demo.csv`](seed_demo.csv)

### 의도한 분포 (인사이트 검증용)
| 항목 | 값 |
|---|---|
| 회원 | 30명 (정회원 25 · 게스트 5) |
| 구매자 | 23명 (미구매 7명 → 전환율 ≈ 77%) |
| 재구매 고객 | 5명 |
| 뉴스레터 구독 | 정회원 중 약 절반 |
| 쿠폰 사용 | 5건 (50%·30%·50000WON) |
| 상품 | proposal·book-aigap 비중 높게, 강좌+도서 혼합 |

## 🗑️ 삭제 방법 (나중에 정리)
모든 데모 계정은 **이메일이 `demo` 로 시작**합니다 (`demo_01@demo.seed`, `demoG_05@guest.test`, `demo_probe1@demo.seed` 등).

**Supabase SQL Editor** 에서 한 줄이면 모두 제거됩니다 (CASCADE로 profiles·enrollments 동반 삭제):
```sql
delete from auth.users where email like 'demo%';
```
전체 스크립트: [`seed_demo_delete.sql`](seed_demo_delete.sql)
또는 **Authentication → Users** 에서 `demo` 검색 후 일괄 삭제해도 됩니다.

## 재생성 방법
이 데이터는 사이트(`index.html`)의 Supabase 클라이언트로 회원가입+구매를 스크립트 삽입한 것입니다.
(가입일/구매일은 `profiles.created_at` 업데이트 및 `enrollments.created_at` 지정으로 백데이트)
필요 시 동일 방식으로 다시 넣을 수 있습니다.

> ⚠️ 가상 데이터이므로 **실제 매출·회원 통계와 섞이지 않도록** 운영 전환 전 반드시 삭제하세요.
