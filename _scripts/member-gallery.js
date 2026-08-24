/* Accessible, opt-in motion for the People page galleries. */
window.addEventListener("DOMContentLoaded", () => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  document.querySelectorAll("[data-member-gallery]").forEach((gallery) => {
    const track = gallery.querySelector("[data-gallery-track]");
    const previous = gallery.querySelector("[data-gallery-prev]");
    const next = gallery.querySelector("[data-gallery-next]");
    const auto = gallery.querySelector("[data-gallery-auto]");
    const progress = gallery.querySelector("[data-gallery-progress]");
    if (!track || !previous || !next) return;

    let autoplay = null;
    let scheduled = false;

    const maximumScroll = () => Math.max(0, track.scrollWidth - track.clientWidth);
    const cardStep = () => {
      const firstCard = track.querySelector(".member-gallery__slide");
      if (!firstCard) return track.clientWidth;
      const styles = window.getComputedStyle(track);
      const gap = Number.parseFloat(styles.columnGap || styles.gap) || 0;
      return firstCard.getBoundingClientRect().width + gap;
    };

    const update = () => {
      const maximum = maximumScroll();
      const position = Math.min(maximum, Math.max(0, track.scrollLeft));
      const hasOverflow = maximum > 2;
      gallery.classList.toggle("is-static", !hasOverflow);
      previous.disabled = position <= 2;
      next.disabled = position >= maximum - 2;
      if (auto) auto.disabled = !hasOverflow;
      if (!hasOverflow && autoplay) stopAutoplay();
      if (progress) {
        const ratio = maximum > 0 ? position / maximum : 1;
        progress.style.transform = `scaleX(${ratio})`;
      }
      scheduled = false;
    };

    const scheduleUpdate = () => {
      if (scheduled) return;
      scheduled = true;
      window.requestAnimationFrame(update);
    };

    const scrollByCard = (direction) => {
      track.scrollBy({
        left: direction * cardStep(),
        behavior: reducedMotion.matches ? "auto" : "smooth",
      });
    };

    const stopAutoplay = (preserveButton = false) => {
      if (autoplay) window.clearInterval(autoplay);
      autoplay = null;
      if (auto && !preserveButton) {
        auto.setAttribute("aria-pressed", "false");
        auto.textContent = auto.dataset.startLabel;
      }
    };

    const startAutoplay = () => {
      if (!auto || reducedMotion.matches) return;
      stopAutoplay(true);
      auto.setAttribute("aria-pressed", "true");
      auto.textContent = auto.dataset.stopLabel;
      autoplay = window.setInterval(() => {
        if (document.hidden || gallery.matches(":hover") || gallery.contains(document.activeElement)) return;
        if (track.scrollLeft >= maximumScroll() - 2) {
          track.scrollTo({ left: 0, behavior: "smooth" });
        } else {
          scrollByCard(1);
        }
      }, 4600);
    };

    previous.addEventListener("click", () => scrollByCard(-1));
    next.addEventListener("click", () => scrollByCard(1));
    track.addEventListener("scroll", scheduleUpdate, { passive: true });
    window.addEventListener("resize", scheduleUpdate, { passive: true });

    if (auto) {
      if (reducedMotion.matches) auto.hidden = true;
      auto.addEventListener("click", () => {
        if (auto.getAttribute("aria-pressed") === "true") stopAutoplay();
        else startAutoplay();
      });
    }

    reducedMotion.addEventListener("change", () => {
      stopAutoplay();
      if (auto) auto.hidden = reducedMotion.matches;
    });

    update();
  });
});
