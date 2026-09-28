/* Shared five-second pacing for the site's exhibitions. */
window.createExhibitAutoplay = (root, advance, options = {}) => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const chinese = document.documentElement.lang === "zh-CN";
  const button = options.button || document.createElement("button");
  if (!options.button) {
    button.type = "button";
    button.className = "exhibit-autoplay";
    root.append(button);
  }
  button.dataset.autoplayToggle = "";
  let enabled = !reducedMotion.matches;
  let visible = false;
  let hovering = false;
  let timer;

  const schedule = () => {
    window.clearTimeout(timer);
    const label = enabled
      ? (chinese ? "暂停自动浏览" : "Pause automatic tour")
      : (chinese ? "开始自动浏览" : "Start automatic tour");
    button.textContent = enabled ? "Ⅱ" : "▶";
    button.setAttribute("aria-label", label);
    button.title = label;
    button.setAttribute("aria-pressed", String(enabled));
    if (!enabled || !visible || hovering || document.hidden || options.canAdvance?.() === false) return;
    timer = window.setTimeout(() => {
      advance();
      schedule();
    }, 5000);
  };

  button.addEventListener("click", () => { enabled = !enabled; schedule(); });
  root.addEventListener("pointerenter", (event) => {
    if (event.pointerType !== "mouse") return;
    hovering = true;
    schedule();
  });
  root.addEventListener("pointerleave", () => { hovering = false; schedule(); });
  root.addEventListener("pointerdown", schedule);
  root.addEventListener("keydown", (event) => {
    if (event.key === "Tab") { enabled = false; schedule(); }
  });
  root.addEventListener("click", schedule);
  document.addEventListener("visibilitychange", schedule);
  reducedMotion.addEventListener("change", () => { enabled = !reducedMotion.matches; schedule(); });
  new IntersectionObserver(([entry]) => {
    visible = entry.isIntersecting;
    schedule();
  }, { threshold: 0.15 }).observe(root);
  schedule();
  return { refresh: schedule };
};
