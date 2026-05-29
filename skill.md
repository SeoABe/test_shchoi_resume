# 바이브 코딩 실습 — 작업 기록

> 강사 소개 홈페이지 (JIsooLab) 제작 과정에서 사용한 기술 및 작업 내역

---

## 1. 프로젝트 구조

```
260528_vibecoding_lec/
├── index.html          # 메인 단일 파일 (HTML + CSS + JS 통합)
├── enterprise.html     # 기업 출강 페이지
├── api/
│   └── query.js        # Vercel Serverless Function (AI API 프록시)
├── images/
│   └── logo.png
├── .env                # API 키 (절대 커밋 금지)
├── .gitignore
└── vercel.json
```

**배포**: Vercel (정적 + 서버리스 함수)

---

## 2. CSS 디자인 토큰 시스템

### 라이트 모드 `:root`
```css
--primary:       #4F46E5;   /* 주 브랜드 색상 */
--accent:        #F59E0B;   /* 강조 색상 */
--text-heading:  #1A1A2E;   /* 제목 텍스트 */
--gray-700:      #374151;   /* 본문 텍스트 */
--gray-500:      #6B7280;   /* 보조/설명 텍스트 */
--gray-100:      #F4F6FA;   /* 섹션 배경 */
--white:         #FFFFFF;
```

### 다크 모드 `[data-theme="dark"]`
```css
--text-heading:  #F1F5F9;   /* 제목 밝게 */
--gray-700:      #CBD5E1;   /* 본문 밝게 */
--gray-500:      #94A3B8;   /* 보조 밝게 */
--gray-100:      #1E293B;
--white:         #0F172A;   /* 배경 완전 다크 */
```

**핵심 원칙**: `var(--white)`는 배경/서피스 토큰이므로 다크 모드에서 `#0F172A`가 됨.
버튼 텍스트 등 항상 흰색이어야 하는 곳은 반드시 `color: #fff` 고정값 사용.

---

## 3. 타이포그래피 규칙

| 목적 | 클래스 / 요소 | 크기 | 색상 토큰 |
|---|---|---|---|
| 페이지 주 제목 | `h1.hero-headline` | `clamp(2rem, 5vw, 3.5rem)` | 그라디언트 |
| 섹션 제목 | `h2.section-title` | `clamp(1.6rem, 3vw, 2.25rem)` | `--text-heading` |
| 서브 제목 | `h3`, `.concept-card-title` | `1.0~1.1rem` | `--text-heading` |
| 본문 설명 | `p.section-desc` | `0.95rem` | `--gray-500` |
| 리스트/카드 내용 | `.career-list li`, `.module-title` | `0.9~0.95rem` | `--text-heading` / `--gray-700` |
| 라벨/메타 | `.module-time`, `.eyebrow` | `0.75~0.8rem` | `--gray-500` / `--primary` |

---

## 4. 반응형 레이아웃

### 브레이크포인트
- `768px` 이하: 태블릿 — 2열 → 1열, 햄버거 메뉴
- `480px` 이하: 모바일 — 패딩 축소, 히어로 세로 정렬
- `360px` 이하: 소형 — 폰트 크기 추가 축소

### 모바일 줄바꿈 헬퍼
```css
.mo-br { display: none; }
@media (max-width: 768px) {
  .mo-br { display: block; }
}
```
```html
<!-- PC: 한 줄 / 모바일: 줄바꿈 -->
AI Transformation, <br class="mo-br">왜 지금인가?
```

---

## 5. 섹션별 배경색 통일 전략

### 라이트 모드
- 모든 섹션: `var(--white)` = `#FFFFFF` 계통
- 히어로만 예외: `linear-gradient(135deg, #EEF2FF, #E0E7FF, #EDE9FE)` (연한 보라)

### 다크 모드
- 모든 섹션: `var(--white)` = `#0F172A` 계통
- 히어로만 예외: 동일하게 `var(--white)` = `#0F172A`

```css
/* 라이트: 회색 섹션도 흰색으로 */
.section-wrap-gray, #section-playground { background: var(--white); }

/* 다크: 동일 규칙이 #0F172A로 자동 적용 */
[data-theme="dark"] .section-wrap-gray,
[data-theme="dark"] #section-playground { background: var(--white); }
```

---

## 6. 컴포넌트 패턴

### 개념 카드 (이모지 + 제목 인라인)
```html
<div class="concept-card">
  <div class="concept-card-header">
    <div class="concept-card-icon">🤖</div>
    <div class="concept-card-title">AI 도구 활용</div>
  </div>
  <div class="concept-card-desc">ChatGPT · Gemini · Claude</div>
</div>
```

### 모듈 아이템 (뱃지 + 2줄 콘텐츠)
```html
<div class="module-item">
  <span class="module-badge" style="background:#EEF2FF;color:#4F46E5;...">입문</span>
  <div class="module-content">
    <div class="module-header">
      <span class="module-title">Module 1 · AI 도구 기초</span>
      <span class="module-time">30분</span>
    </div>
    <div class="module-sub">ChatGPT · Gemini · Claude 첫 걸음</div>
  </div>
</div>
```

### 경력 리스트 (PC 1줄 / 모바일 2줄)
```html
<li>
  <span>어린이 의사체험센터 '드림닥터' 인스타그램 마케팅<br class="mo-br">
  → <strong>팔로워 83% 증가, 조회수 12만</strong></span>
</li>
```
**주의**: `<li>` 안에서 `<strong>`이 flex item으로 분리되는 버그 방지를 위해 반드시 `<span>`으로 감싸야 함.

### 데모 카드 (다크/라이트 대응 클래스)
```html
<div class="demo-card">
  <div style="font-size:1.6rem;margin-bottom:10px;">📱</div>
  <div class="dc-title">SNS 콘텐츠 쿼리</div>
  <div class="dc-sub">인스타그램 · 카드뉴스 · 릴스</div>
  <div style="font-size:0.8rem;color:var(--secondary);font-weight:600;">📈 팔로워 반응 3배↑</div>
  <div class="dc-hint">클릭해서 예시 보기 →</div>
</div>
```
- `.dc-title` / `.dc-sub` / `.dc-hint`: 다크 모드에서 자동으로 밝은 색으로 전환
- 포인트 색(accent, secondary, green)은 inline style로 고정

---

## 7. AI 플레이그라운드 (Vercel Serverless)

### 동작 방식
1. 사용자가 마케팅 상황 입력
2. `POST /api/query` 호출
3. Anthropic or OpenAI API에 요청 (키 prefix로 자동 판별)
4. 결과를 마크다운 렌더링하여 표시

### API 키 판별 로직
```javascript
const isOpenAI = effectiveKey.startsWith('sk-') && !effectiveKey.startsWith('sk-ant-');
```

### 마크다운 렌더링
```javascript
function renderMarkdown(text) {
  return text
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/\n/g, '<br>');
}
```

---

## 8. 다크/라이트 모드 토글

```javascript
const saved = localStorage.getItem('theme') || 'dark';
document.documentElement.setAttribute('data-theme', saved);

themeToggle.addEventListener('click', () => {
  const next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('theme', next);
});
```

---

## 9. 로고 가시성 (투명 PNG)

```css
/* 배경에 상관없이 로고 외곽선 처리 */
filter: drop-shadow(0 0 1px rgba(26,26,46,0.9))
        drop-shadow(0 0 1px rgba(26,26,46,0.6));
```

---

## 10. 모달 시스템

### 수강신청 모달
- 커스텀 드롭다운(`.custom-select`) — OS 기본 select 대신 div 기반 구현
- 인라인 에러 메시지(`.form-error` + shake 애니메이션) — alert() 대체
- `openModal()` 호출 시 폼 완전 초기화
- 모달 헤더 `::after` 웨이브: `z-index:0` + 헤더 `padding-bottom:48px`로 텍스트 가림 방지

### 개인정보/이용약관 모달
```javascript
// 조 3개마다 구간 동의 버튼 삽입
// 버튼 3개 모두 클릭해야 최종 동의 활성화
termsBody.addEventListener('click', e => {
  const btn = e.target.closest('.terms-section-agree');
  if (!btn || btn.classList.contains('agreed')) return;
  btn.classList.add('agreed');
  btn.textContent = '✓ 동의 완료';
  const total   = termsBody.querySelectorAll('.terms-section-agree').length;
  const agreed  = termsBody.querySelectorAll('.terms-section-agree.agreed').length;
  termsProg.style.width = (agreed / total * 100) + '%';
  if (agreed === total) activateAgree();
  else termsHint.textContent = `각 항목을 읽고 동의 버튼을 눌러주세요 (${agreed}/${total})`;
});
```
- 진행률 바: 동의된 구간 수 / 전체 구간 수
- 푸터 링크 클릭 → `openTermsModal('privacy')` / `openTermsModal('terms')`

---

## 11. FAQ — 더 보기 패턴

```css
.faq-item.faq-hidden { display: none; }
```
```html
<!-- 4번째 항목부터 faq-hidden 클래스 추가 -->
<div class="faq-item faq-hidden">...</div>
<button class="faq-more-btn" id="faq-more-btn">더 보기 <span id="faq-more-icon">▾</span></button>
```
```javascript
let faqExpanded = false;
faqMoreBtn.addEventListener('click', () => {
  faqExpanded = !faqExpanded;
  document.querySelectorAll('.faq-item.faq-hidden').forEach(item => {
    item.style.display = faqExpanded ? 'block' : '';
  });
  faqMoreBtn.childNodes[0].textContent = faqExpanded ? '접기 ' : '더 보기 ';
  faqMoreIcon.textContent = faqExpanded ? '▴' : '▾';
});
```

---

## 12. 푸터 구성

### 소개 문구 (3줄 분리)
```html
<p>브랜드와 고객을 연결하는<br>SNS 마케터, AI 강사 김지수의<br>공식 교육 플랫폼입니다.</p>
```

### 연락처 버튼
```html
<a href="mailto:mymama09@naver.com" class="footer-contact-btn">✉ mymama09@naver.com</a>
<a href="tel:010-2820-8928" class="footer-contact-btn">📞 010-2820-8928</a>
```

### SNS 링크
- Instagram → `https://www.instagram.com/`
- LinkedIn → `https://www.linkedin.com/`
- 당근 → 앱 딥링크 + 미설치 시 스토어 이동 (아래 참고)

### 당근 앱 딥링크 패턴
```javascript
function openDaangn() {
  const isIOS     = /iPhone|iPad|iPod/i.test(navigator.userAgent);
  const isAndroid = /Android/i.test(navigator.userAgent);
  const appStore  = 'https://apps.apple.com/kr/app/%EB%8B%B9%EA%B7%BC/id1018769995';
  const playStore = 'https://play.google.com/store/apps/details?id=com.towneers.www';

  if (isIOS) {
    window.location.href = 'daangn://';
    setTimeout(() => { window.location.href = appStore; }, 1500);
  } else if (isAndroid) {
    window.location.href = 'daangn://';
    setTimeout(() => { window.location.href = playStore; }, 1500);
  } else {
    window.open('https://www.daangn.com/', '_blank', 'noopener');
  }
}
```

---

## 13. 배포 명령어

```bash
vercel           # 프리뷰 배포
vercel --prod    # 프로덕션 배포
```

---

## 트러블슈팅 메모

| 문제 | 원인 | 해결 |
|---|---|---|
| `<strong>` 이 flex 컬럼으로 분리됨 | `<li>` 가 `display:flex` 이고 inline 자식이 flex item이 됨 | `<span>` 으로 감싸기 |
| 다크모드에서 제목 텍스트 불가시 | `color: var(--dark)`는 모드에 관계없이 `#1A1A2E` 고정 | `var(--text-heading)` 토큰 사용 |
| 버튼/네비 텍스트 다크 모드에서 안 보임 | `color: var(--white)` 가 다크 모드에서 `#0F172A`(검정)으로 변함 | `color: #fff` 고정값 사용 |
| 푸터 제목 다크 모드에서 안 보임 | 동일 — `color: var(--white)` 사용 | `color: #fff` 고정값 사용 |
| 한국어 단어 중간 줄바꿈 | CSS 기본 word-break | `word-break: keep-all` 전역 적용 |
| 모바일에서 의미 단위 줄바꿈 | CSS만으로는 특정 위치 제어 불가 | `<br class="mo-br">` 헬퍼 클래스 |
| 마크다운 `**굵게**` 그대로 출력 | `innerHTML` 없이 `textContent` 사용 | `renderMarkdown()` 함수 적용 |
| 가격 카드 라이트 모드에서 텍스트 안 보임 | 인라인 `color:#fff` 이 라이트 배경에 그대로 표시 | `.price-tier:not(.featured) p { color: var(--gray-700) !important }` |
| 데모 카드 라이트 모드에서 텍스트 안 보임 | 인라인 `color:#fff / rgba(255,255,255,X)` 고정 | `.dc-title`, `.dc-sub`, `.dc-hint` 클래스로 교체 |
| 모달 부제목이 웨이브에 가림 | `::after` 웨이브가 텍스트 위에 렌더링됨 | `::after` 에 `z-index:0`, 헤더 `padding-bottom:48px` |
| OS 기본 select 드롭다운이 모달 밖으로 나감 | 브라우저 네이티브 UI는 z-index 제어 불가 | 커스텀 div 드롭다운으로 교체 |
| 수강신청 재열 시 이전 내용 남음 | openModal()에서 폼 초기화 안 함 | openModal()에 value/classList 초기화 추가 |
| eyebrow 다크 모드 대비 부족 | `#4F46E5` on `#1E293B` = 대비율 2.7:1 | `[data-theme="dark"] .eyebrow { color: #a5b4fc }` |
| 당근마켓 링크 — 웹 페이지 없음 | 당근은 앱 전용 서비스 | `daangn://` 딥링크 + 미설치 시 스토어 이동 |
