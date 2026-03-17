(async () => {
  if (window.__heartMoveEffectInitialized__) {
    return;
  }

  window.__heartMoveEffectInitialized__ = true;

  const hearts = [];
  let enabled = true;
  let moveCooldown = 0;

  function randomColor() {
    const red = Math.floor(Math.random() * 256);
    const green = Math.floor(Math.random() * 256);
    const blue = Math.floor(Math.random() * 256);
    return `rgb(${red}, ${green}, ${blue})`;
  }

  function injectStyle() {
    const style = document.createElement("style");
    style.textContent = `
      .heart-move-effect {
        position: fixed;
        width: 10px;
        height: 10px;
        transform: rotate(45deg);
        pointer-events: none;
        z-index: 2147483647;
      }

      .heart-move-effect::before,
      .heart-move-effect::after {
        content: "";
        position: absolute;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: inherit;
      }

      .heart-move-effect::before {
        left: -5px;
      }

      .heart-move-effect::after {
        top: -5px;
      }
    `;
    document.documentElement.appendChild(style);
  }

  function createHeart(x, y) {
    if (!enabled || !document.body) {
      return;
    }

    const heart = document.createElement("div");
    heart.className = "heart-move-effect";
    heart.style.background = randomColor();

    hearts.push({
      element: heart,
      x: x - 5,
      y: y - 5,
      scale: 1,
      alpha: 1
    });

    document.body.appendChild(heart);
  }

  function createRandomHeart() {
    const width = document.documentElement.clientWidth;
    const height = document.documentElement.clientHeight;
    const x = Math.ceil(Math.random() * width);
    const y = Math.ceil(Math.random() * height);
    createHeart(x, y);
  }

  function animate() {
    for (let i = hearts.length - 1; i >= 0; i -= 1) {
      const heart = hearts[i];

      if (heart.alpha <= 0) {
        heart.element.remove();
        hearts.splice(i, 1);
        continue;
      }

      heart.y -= 1;
      heart.scale += 0.004;
      heart.alpha -= 0.013;
      heart.element.style.left = `${heart.x}px`;
      heart.element.style.top = `${heart.y}px`;
      heart.element.style.opacity = String(heart.alpha);
      heart.element.style.transform = `scale(${heart.scale}) rotate(45deg)`;
    }

    window.requestAnimationFrame(animate);
  }

  function handlePointerMove() {
    if (!enabled) {
      return;
    }

    const now = Date.now();
    if (now - moveCooldown < 40) {
      return;
    }

    moveCooldown = now;
    createRandomHeart();
  }

  function setEnabledState(nextValue) {
    enabled = nextValue;
  }

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes.enabled) {
      return;
    }

    setEnabledState(Boolean(changes.enabled.newValue));
  });

  chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
    if (message?.type !== "HEART_EFFECT_SET_ENABLED") {
      return;
    }

    setEnabledState(Boolean(message.enabled));
    sendResponse({ ok: true });
  });

  const stored = await chrome.storage.sync.get("enabled");
  setEnabledState(stored.enabled ?? true);

  injectStyle();
  document.addEventListener("pointermove", handlePointerMove, { passive: true });
  window.requestAnimationFrame(animate);
})();
