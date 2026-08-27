window.addEventListener("DOMContentLoaded", () => {
  const root = document.querySelector("[data-research-page]");
  const rail = root?.querySelector("[data-research-rail]");
  const cards = [...(root?.querySelectorAll("[data-research-card]") || [])];
  const jumps = [...(root?.querySelectorAll("[data-research-jump]") || [])];
  const previous = root?.querySelector("[data-research-previous]");
  const next = root?.querySelector("[data-research-next]");
  const position = root?.querySelector("[data-research-position]");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  if (!rail || cards.length === 0) return;

  let activeIndex = 0;

  const setActive = (index) => {
    activeIndex = Math.max(0, Math.min(cards.length - 1, index));
    if (position) position.textContent = String(activeIndex + 1).padStart(2, "0");
    jumps.forEach((jump, jumpIndex) => {
      jump.classList.toggle("is-active", jumpIndex === activeIndex);
      if (jumpIndex === activeIndex) jump.setAttribute("aria-current", "true");
      else jump.removeAttribute("aria-current");
    });
  };

  const goTo = (index, updateHash = false) => {
    const targetIndex = Math.max(0, Math.min(cards.length - 1, index));
    cards[targetIndex].scrollIntoView({
      behavior: reducedMotion.matches ? "auto" : "smooth",
      block: "nearest",
      inline: "start",
    });
    setActive(targetIndex);
    if (updateHash) window.history.replaceState(null, "", `#${cards[targetIndex].id}`);
  };

  previous?.addEventListener("click", () => goTo(activeIndex - 1, true));
  next?.addEventListener("click", () => goTo(activeIndex + 1, true));
  jumps.forEach((jump, index) => jump.addEventListener("click", (event) => {
    event.preventDefault();
    goTo(index, true);
  }));

  rail.addEventListener("keydown", (event) => {
    if (event.key === "ArrowLeft") {
      event.preventDefault();
      goTo(activeIndex - 1, true);
    }
    if (event.key === "ArrowRight") {
      event.preventDefault();
      goTo(activeIndex + 1, true);
    }
  });

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver((entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
      if (visible) setActive(cards.indexOf(visible.target));
    }, { root: rail, threshold: [0.45, 0.65, 0.85] });
    cards.forEach((card) => observer.observe(card));
  }

  const hashIndex = cards.findIndex((card) => `#${card.id}` === window.location.hash);
  setActive(hashIndex >= 0 ? hashIndex : 0);
  if (hashIndex >= 0) window.requestAnimationFrame(() => goTo(hashIndex));
});
