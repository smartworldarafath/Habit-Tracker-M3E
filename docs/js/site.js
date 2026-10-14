const root = document.documentElement;
const calm = matchMedia('(prefers-reduced-motion: reduce)').matches;

const store = (key, value) => {
  try {
    if (value === undefined) return localStorage.getItem(key);
    localStorage.setItem(key, value);
  } catch {
    return null;
  }
  return value;
};

// Theme toggle
const themeBtn = document.getElementById('theme-toggle');
if (themeBtn) {
  themeBtn.addEventListener('click', () => {
    const isLight = root.dataset.theme === 'light';
    const nextTheme = isLight ? 'dark' : 'light';
    root.dataset.theme = nextTheme;
    store('m3e-theme', nextTheme);
  });
}

// Language switcher
const langBtn = document.getElementById('lang');
if (langBtn) {
  langBtn.addEventListener('click', () => {
    const next = root.dataset.lang === 'es' ? 'en' : 'es';
    store('streak-lang', next);
    root.dataset.lang = next;
    root.lang = next;
  });
}

// Sticky header border on scroll
const bar = document.querySelector('.bar');
if (bar) {
  const onScroll = () => bar.classList.toggle('is-down', window.scrollY > 8);
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
}

// Animated number counter
function countUp(node, to) {
  if (calm) {
    node.textContent = to.toLocaleString();
    return;
  }
  const start = performance.now();
  const step = (now) => {
    const t = Math.min(1, (now - start) / 1600);
    node.textContent = Math.round(to * (1 - (1 - t) ** 4)).toLocaleString();
    if (t < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

function whenSeen(node, run) {
  const seen = new IntersectionObserver((entries) => {
    if (!entries[0].isIntersecting) return;
    seen.disconnect();
    run();
  });
  seen.observe(node);
}

function counter(name) {
  const nodes = [...document.querySelectorAll(`[data-count="${name}"]`)];
  const saved = Number(store(`m3e-${name}`)) || 0;
  let value = saved;
  const shown = new Set();
  const show = (node) => {
    if (!value || shown.has(node)) return;
    shown.add(node);
    countUp(node, value);
  };
  nodes.forEach((node) => {
    node.textContent = saved > 0 ? saved.toLocaleString() : '—';
    whenSeen(node, () => {
      node.dataset.seen = '1';
      show(node);
    });
  });
  return (fresh) => {
    if (typeof fresh !== 'number' || !nodes.length) return;
    store(`m3e-${name}`, fresh);
    value = fresh;
    nodes.forEach((node) => {
      if (!node.dataset.seen) return;
      if (shown.has(node)) node.textContent = fresh.toLocaleString();
      else show(node);
    });
  };
}

// Fetch GitHub stats for smartworldarafath/Habit-Tracker-M3E
const setStars = counter('stars');
fetch('https://api.github.com/repos/smartworldarafath/Habit-Tracker-M3E')
  .then((res) => (res.ok ? res.json() : null))
  .then((repo) => setStars(repo && repo.stargazers_count))
  .catch(() => {});

if (document.querySelector('[data-count="downloads"]')) {
  const setDownloads = counter('downloads');
  fetch('https://api.github.com/repos/smartworldarafath/Habit-Tracker-M3E/releases?per_page=100')
    .then((res) => (res.ok ? res.json() : null))
    .then((releases) => {
      if (!Array.isArray(releases)) return;
      let total = 0;
      releases.forEach((release) => {
        (release.assets || []).forEach((asset) => {
          total += asset.download_count || 0;
        });
      });
      setDownloads(total);
    })
    .catch(() => {});
}

// Ambient Heatmap Grid with M3E brand orange glow
const heat = document.getElementById('heat');
if (heat) {
  const cells = [];
  for (let i = 0; i < 30 * 22; i += 1) {
    const cell = document.createElement('i');
    heat.appendChild(cell);
    cells.push(cell);
  }
  const paint = (cell) => {
    const on = Math.random() > 0.44;
    const level = 0.22 + Math.random() * 0.55;
    cell.style.background = on
      ? `rgba(255, 107, 0, ${level.toFixed(2)})`
      : 'rgba(255, 255, 255, .05)';
    cell.style.boxShadow = on && level > 0.58
      ? '0 0 10px rgba(255, 107, 0, .45)'
      : 'none';
  };
  cells.forEach(paint);
  if (!calm) {
    setInterval(() => {
      for (let i = 0; i < 4; i += 1) {
        paint(cells[Math.floor(Math.random() * cells.length)]);
      }
    }, 700);
  }
}

// Horizontal screenshot shelf & light/dark switching button
const shelf = document.getElementById('shelf');
const shelfSwitchBtn = document.getElementById('shelf-mode-toggle');
let currentShelfMode = 'light'; // Default is always light screens

function applyShelfMode(mode) {
  currentShelfMode = mode;
  if (shelf) {
    shelf.dataset.mode = mode;
  }
  if (shelfSwitchBtn) {
    const isDark = mode === 'dark';
    shelfSwitchBtn.classList.toggle('is-dark-active', isDark);
    shelfSwitchBtn.setAttribute('aria-pressed', isDark ? 'true' : 'false');
    shelfSwitchBtn.dataset.activeMode = mode;
  }
}

if (shelfSwitchBtn) {
  shelfSwitchBtn.addEventListener('click', () => {
    const nextMode = currentShelfMode === 'dark' ? 'light' : 'dark';
    applyShelfMode(nextMode);
  });
}

// Initial state: default is light screens
applyShelfMode('light');

if (shelf) {
  const [back, next] = document.querySelectorAll('[data-shelf]');
  const step = () => {
    const firstShot = shelf.querySelector('.shot');
    return firstShot ? firstShot.offsetWidth + 26 : 256;
  };
  const sync = () => {
    if (back) back.disabled = shelf.scrollLeft < 8;
    if (next) next.disabled = shelf.scrollLeft + shelf.clientWidth > shelf.scrollWidth - 8;
  };
  document.querySelectorAll('[data-shelf]').forEach((button) => {
    button.addEventListener('click', () => {
      shelf.scrollBy({ left: Number(button.dataset.shelf) * step() * 2 });
    });
  });
  shelf.addEventListener('scroll', sync, { passive: true });
  window.addEventListener('resize', sync);
  sync();
}

// Fullscreen Lightbox preview dialog
const lb = document.getElementById('lb');
if (lb) {
  const lbStage = lb.querySelector('.lb__stage');
  const lbCap = lb.querySelector('.lb__cap');
  let lbList = [];
  let lbAt = 0;

  const captionOf = (el) => {
    const item = el.closest('.shot, .item');
    if (!item) return '';
    const label = item.querySelector('figcaption, h3');
    if (!label) return '';
    const shown = [...label.querySelectorAll('.en, .es')].find(
      (span) => span.offsetParent !== null
    );
    return (shown || label).textContent.trim();
  };

  const showAt = (index) => {
    lbAt = (index + lbList.length) % lbList.length;
    const el = lbList[lbAt];
    lbStage.innerHTML = '';
    const media = document.createElement('img');
    const isLight = shelf && shelf.dataset.mode === 'light';
    const activeImg = isLight
      ? (el.querySelector('.shot__img--light') || el.querySelector('img'))
      : (el.querySelector('.shot__img--dark') || el.querySelector('img'));
    const src = isLight
      ? (el.dataset.srcLight || (activeImg ? activeImg.src : ''))
      : (el.dataset.srcDark || (activeImg ? activeImg.src : ''));
    media.src = src || el.dataset.src || (activeImg ? activeImg.currentSrc || activeImg.src : '');
    media.alt = activeImg ? activeImg.alt : '';
    media.className = 'is-phone';
    lbStage.appendChild(media);
    lbCap.textContent = captionOf(el);
    lb.querySelectorAll('.lb__nav').forEach((nav) => {
      nav.hidden = lbList.length < 2;
    });
  };

  document.querySelectorAll('.zoom').forEach((el) => {
    el.addEventListener('click', () => {
      lbList = [...document.querySelectorAll(`.zoom[data-group="${el.dataset.group}"]`)].filter(
        (other) => !other.closest('[hidden]')
      );
      lb.showModal();
      showAt(lbList.indexOf(el));
    });
  });

  lb.addEventListener('click', (event) => {
    const action = event.target.closest('[data-lb]');
    if (action) {
      if (action.dataset.lb === 'close') lb.close();
      else showAt(lbAt + Number(action.dataset.lb));
      return;
    }
    if (event.target === lb || event.target === lbStage) lb.close();
  });

  lb.addEventListener('close', () => {
    lbStage.innerHTML = '';
  });

  window.addEventListener('keydown', (event) => {
    if (!lb.open) return;
    if (event.key === 'ArrowRight') showAt(lbAt + 1);
    if (event.key === 'ArrowLeft') showAt(lbAt - 1);
  });
}

// Share button with clipboard copy feedback
document.querySelectorAll('[data-share]').forEach((button) => {
  button.addEventListener('click', async () => {
    const url = button.dataset.share;
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Habit Tracker M3E',
          text: document.title,
          url,
        });
        return;
      } catch (error) {
        if (error && error.name === 'AbortError') return;
      }
    }
    try {
      await navigator.clipboard.writeText(url);
    } catch {
      return;
    }
    button.classList.add('is-copied');
    setTimeout(() => button.classList.remove('is-copied'), 2600);
  });
});
