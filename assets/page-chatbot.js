(() => {
  const ENDPOINT = resolveEndpoint();
  const STORAGE_KEY = 'sanghun-page-chatbot-messages';
  const MAX_CONTEXT_LENGTH = 18000;
  const MAX_HISTORY_ITEMS = 8;

  const state = {
    open: false,
    busy: false,
    messages: loadMessages(),
  };

  const root = document.createElement('aside');
  root.className = 'page-chatbot';
  root.setAttribute('aria-label', '페이지 챗봇');
  root.innerHTML = `
    <section class="page-chatbot__panel" aria-label="채팅 창">
      <header class="page-chatbot__header">
        <div>
          <p class="page-chatbot__title">SANGHUN.AI 챗봇</p>
          <p class="page-chatbot__status" data-chat-status>홈페이지 내용 기준</p>
        </div>
        <button class="page-chatbot__close" type="button" aria-label="닫기">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg>
        </button>
      </header>
      <div class="page-chatbot__messages" data-chat-messages></div>
      <form class="page-chatbot__composer" data-chat-form>
        <textarea class="page-chatbot__input" data-chat-input rows="1" placeholder="궁금한 내용을 입력하세요" aria-label="챗봇 질문"></textarea>
        <button class="page-chatbot__send" type="submit" aria-label="보내기">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/></svg>
        </button>
      </form>
    </section>
    <button class="page-chatbot__toggle" type="button" aria-label="챗봇 열기" aria-expanded="false">
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4z"/></svg>
    </button>
  `;

  document.body.appendChild(root);

  const toggleBtn = root.querySelector('.page-chatbot__toggle');
  const closeBtn = root.querySelector('.page-chatbot__close');
  const messagesEl = root.querySelector('[data-chat-messages]');
  const formEl = root.querySelector('[data-chat-form]');
  const inputEl = root.querySelector('[data-chat-input]');
  const statusEl = root.querySelector('[data-chat-status]');
  const sendBtn = root.querySelector('.page-chatbot__send');

  toggleBtn.addEventListener('click', () => setOpen(!state.open));
  closeBtn.addEventListener('click', () => setOpen(false));
  formEl.addEventListener('submit', onSubmit);
  inputEl.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      formEl.requestSubmit();
    }
  });
  inputEl.addEventListener('input', resizeInput);

  if (!state.messages.length) {
    state.messages.push({
      role: 'assistant',
      content: '안녕하세요. 이 페이지에 있는 소개, 강의, 경력, 문의 정보 안에서 답변드릴게요.',
    });
  }

  render();

  async function onSubmit(event) {
    event.preventDefault();
    const question = inputEl.value.trim();
    if (!question || state.busy) return;

    inputEl.value = '';
    resizeInput();
    state.messages.push({ role: 'user', content: question });
    state.busy = true;
    persistMessages();
    render();

    const typingMessage = { role: 'assistant', content: '확인하고 있습니다...' };
    state.messages.push(typingMessage);
    render();

    try {
      if (!ENDPOINT) {
        throw new Error('Vercel API URL is not configured.');
      }

      const response = await fetch(ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: question,
          messages: state.messages
            .filter((message) => message.role === 'user' || message.role === 'assistant')
            .slice(-MAX_HISTORY_ITEMS)
            .map(({ role, content }) => ({ role, content })),
          pageContext: collectPageContext(),
        }),
      });

      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(data.error || '챗봇 응답을 받지 못했습니다.');
      }

      typingMessage.content = data.reply || '이 페이지에서 확인할 수 없습니다.';
    } catch (error) {
      typingMessage.content = [
        '지금은 챗봇 서버에 연결할 수 없습니다.',
        getEndpointHelp(),
        `오류: ${error.message}`,
      ].join('\n');
    } finally {
      state.busy = false;
      persistMessages();
      render();
      inputEl.focus();
    }
  }

  function collectPageContext() {
    const candidates = [...document.querySelectorAll('nav, section, footer')];
    const text = candidates
      .map((element) => element.innerText || element.textContent || '')
      .join('\n\n')
      .replace(/\s+\n/g, '\n')
      .replace(/\n{3,}/g, '\n\n')
      .replace(/[ \t]{2,}/g, ' ')
      .trim();

    return text.slice(0, MAX_CONTEXT_LENGTH);
  }

  function setOpen(open) {
    state.open = open;
    root.classList.toggle('open', open);
    toggleBtn.setAttribute('aria-expanded', String(open));
    toggleBtn.setAttribute('aria-label', open ? '챗봇 닫기' : '챗봇 열기');
    if (open) {
      requestAnimationFrame(() => inputEl.focus());
    }
  }

  function render() {
    messagesEl.innerHTML = '';
    state.messages.forEach((message) => {
      const node = document.createElement('div');
      node.className = `page-chatbot__message page-chatbot__message--${message.role}`;
      node.textContent = message.content;
      messagesEl.appendChild(node);
    });
    messagesEl.scrollTop = messagesEl.scrollHeight;
    inputEl.disabled = state.busy;
    sendBtn.disabled = state.busy;
    statusEl.textContent = state.busy ? '답변 작성 중' : '홈페이지 내용 기준';
  }

  function resizeInput() {
    inputEl.style.height = 'auto';
    inputEl.style.height = `${Math.min(inputEl.scrollHeight, 120)}px`;
  }

  function loadMessages() {
    try {
      const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
      return Array.isArray(parsed) ? parsed.slice(-12) : [];
    } catch {
      return [];
    }
  }

  function persistMessages() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state.messages.slice(-12)));
  }

  function resolveEndpoint() {
    const configured = String(window.SANGHUN_CHAT_API_URL || '').trim();
    if (configured) return configured;

    if (location.hostname === 'localhost' || location.hostname === '127.0.0.1') {
      return '/api/chat';
    }

    return '';
  }

  function getEndpointHelp() {
    if (ENDPOINT) {
      return `챗봇 API 주소(${ENDPOINT})와 Vercel 환경변수를 확인해 주세요.`;
    }

    return 'GitHub Pages에서는 assets/page-chatbot-config.js의 window.SANGHUN_CHAT_API_URL에 Vercel API 주소를 설정해야 합니다.';
  }
})();
