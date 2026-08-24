/* Subtle image parallax for member profiles; disabled for reduced motion. */
window.addEventListener("DOMContentLoaded", () => {
  const profile = document.querySelector("[data-member-profile]");
  const visual = profile?.querySelector("[data-member-visual]");
  if (!profile || !visual) return;

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  let scheduled = false;

  const update = () => {
    if (reducedMotion.matches) {
      visual.style.setProperty("--member-photo-shift", "0px");
      scheduled = false;
      return;
    }

    const rect = profile.getBoundingClientRect();
    const travel = Math.max(window.innerHeight + rect.height, 1);
    const progress = Math.min(1, Math.max(0, (window.innerHeight - rect.top) / travel));
    visual.style.setProperty("--member-photo-shift", `${(progress - 0.5) * 34}px`);
    scheduled = false;
  };

  const scheduleUpdate = () => {
    if (scheduled) return;
    scheduled = true;
    window.requestAnimationFrame(update);
  };

  update();
  window.addEventListener("scroll", scheduleUpdate, { passive: true });
  window.addEventListener("resize", scheduleUpdate, { passive: true });
  reducedMotion.addEventListener("change", scheduleUpdate);
});
