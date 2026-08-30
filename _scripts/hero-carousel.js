/* Accessible, dependency-free carousel for the homepage information-flow images. */
window.addEventListener("DOMContentLoaded", () => {
  const carousel = document.querySelector("[data-hero-carousel]");
  if (!carousel) return;

  const viewport = carousel.querySelector("[data-hero-carousel-viewport]");
  const track = carousel.querySelector("[data-hero-carousel-track]");
  const slides = [...carousel.querySelectorAll("[data-hero-carousel-slide]")];
  const previous = carousel.querySelector("[data-hero-carousel-previous]");
  const next = carousel.querySelector("[data-hero-carousel-next]");
  const toggle = carousel.querySelector("[data-hero-carousel-toggle]");
  const current = carousel.querySelector("[data-hero-carousel-current]");
  const currentTitle = carousel.querySelector("[data-hero-carousel-title]");
  const status = carousel.querySelector("[data-hero-carousel-status]");
  const progress = carousel.querySelector("[data-hero-carousel-progress]");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const pauseLabel = carousel.dataset.pauseLabel || "Pause carousel";
  const playLabel = carousel.dataset.playLabel || "Resume carousel";

  if (!viewport || !track || slides.length < 2 || !previous || !next || !toggle) return;

  let activeIndex = 0;
  let timer;
  let pointerStart;
  let temporarilyPaused = false;
  let inView = true;
  let userPaused = reducedMotion.matches;

  const formatIndex = (index) => String(index + 1).padStart(2, "0");

  const render = () => {
    track.style.transform = `translate3d(-${activeIndex * 100}%, 0, 0)`;
    slides.forEach((slide, index) => slide.setAttribute("aria-hidden", String(index !== activeIndex)));
    if (current) current.textContent = formatIndex(activeIndex);
    if (currentTitle) currentTitle.textContent = ` — ${slides[activeIndex].dataset.title || ""}`;
    if (progress) progress.style.transform = `scaleX(${(activeIndex + 1) / slides.length})`;
  };

  const shouldAutoplay = () => !userPaused && !temporarilyPaused && !reducedMotion.matches && inView && !document.hidden;

  const stopTimer = () => {
    window.clearInterval(timer);
    timer = undefined;
  };

  const updatePlayback = () => {
    stopTimer();
    const isPlaying = shouldAutoplay();
    toggle.setAttribute("aria-label", userPaused ? playLabel : pauseLabel);
    toggle.querySelector("span").textContent = userPaused ? "▶" : "Ⅱ";
    if (status) status.setAttribute("aria-live", userPaused ? "polite" : "off");
    if (isPlaying) timer = window.setInterval(() => goTo(activeIndex + 1), 6500);
  };

  const goTo = (index) => {
    activeIndex = (index + slides.length) % slides.length;
    render();
  };

  previous.addEventListener("click", () => {
    goTo(activeIndex - 1);
    updatePlayback();
  });

  next.addEventListener("click", () => {
    goTo(activeIndex + 1);
    updatePlayback();
  });

  toggle.addEventListener("click", () => {
    userPaused = !userPaused;
    updatePlayback();
  });

  carousel.addEventListener("keydown", (event) => {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    event.preventDefault();
    goTo(activeIndex + (event.key === "ArrowRight" ? 1 : -1));
    updatePlayback();
  });

  carousel.addEventListener("mouseenter", () => {
    temporarilyPaused = true;
    updatePlayback();
  });

  carousel.addEventListener("mouseleave", () => {
    temporarilyPaused = false;
    updatePlayback();
  });

  carousel.addEventListener("focusin", () => {
    temporarilyPaused = true;
    updatePlayback();
  });

  carousel.addEventListener("focusout", (event) => {
    if (carousel.contains(event.relatedTarget)) return;
    temporarilyPaused = false;
    updatePlayback();
  });

  viewport.addEventListener("pointerdown", (event) => {
    pointerStart = event.clientX;
    viewport.setPointerCapture(event.pointerId);
  });

  viewport.addEventListener("pointerup", (event) => {
    if (pointerStart === undefined) return;
    const distance = event.clientX - pointerStart;
    pointerStart = undefined;
    if (Math.abs(distance) < 45) return;
    goTo(activeIndex + (distance < 0 ? 1 : -1));
    updatePlayback();
  });

  viewport.addEventListener("pointercancel", () => {
    pointerStart = undefined;
  });

  document.addEventListener("visibilitychange", updatePlayback);
  reducedMotion.addEventListener("change", () => {
    if (reducedMotion.matches) userPaused = true;
    updatePlayback();
  });

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(([entry]) => {
      inView = entry.isIntersecting;
      updatePlayback();
    }, { threshold: 0.2 });
    observer.observe(carousel);
  }

  render();
  updatePlayback();
});
