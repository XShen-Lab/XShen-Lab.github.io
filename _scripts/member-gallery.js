/* Member cards share the exhibition's five-second pacing. */
window.addEventListener("DOMContentLoaded", () => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  document.querySelectorAll("[data-member-gallery]").forEach((gallery) => {
    const track = gallery.querySelector("[data-gallery-track]");
    const previous = gallery.querySelector("[data-gallery-prev]");
    const next = gallery.querySelector("[data-gallery-next]");
    const auto = gallery.querySelector("[data-gallery-auto]");
    const progress = gallery.querySelector("[data-gallery-progress]");
    if (!track || !previous || !next) return;

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

    previous.addEventListener("click", () => scrollByCard(-1));
    next.addEventListener("click", () => scrollByCard(1));
    track.addEventListener("scroll", scheduleUpdate, { passive: true });
    window.addEventListener("resize", scheduleUpdate, { passive: true });

    update();
    const tour = window.createExhibitAutoplay(gallery, () => {
      if (track.scrollLeft >= maximumScroll() - 2) track.scrollTo({ left: 0, behavior: "smooth" });
      else scrollByCard(1);
    }, { button: auto, canAdvance: () => maximumScroll() > 2 });
    window.addEventListener("resize", tour.refresh, { passive: true });
  });
});
