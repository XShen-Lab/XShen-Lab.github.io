/* Accessible, dependency-free carousel for the homepage information-flow images. */
window.addEventListener("DOMContentLoaded", () => {
  const carousel = document.querySelector("[data-hero-carousel]");
  if (!carousel) return;

  const viewport = carousel.querySelector("[data-hero-carousel-viewport]");
  const track = carousel.querySelector("[data-hero-carousel-track]");
  const slides = [...carousel.querySelectorAll("[data-hero-carousel-slide]")];
  const previous = carousel.querySelector("[data-hero-carousel-previous]");
  const next = carousel.querySelector("[data-hero-carousel-next]");
  const current = carousel.querySelector("[data-hero-carousel-current]");
  const currentTitle = carousel.querySelector("[data-hero-carousel-title]");

  if (!viewport || !track || slides.length < 2 || !previous || !next) return;

  let activeIndex = 0;
  let pointerStart;

  const formatIndex = (index) => String(index + 1).padStart(2, "0");

  const render = () => {
    track.style.transform = `translate3d(-${activeIndex * 100}%, 0, 0)`;
    slides.forEach((slide, index) => slide.setAttribute("aria-hidden", String(index !== activeIndex)));
    if (current) current.textContent = formatIndex(activeIndex);
    if (currentTitle) currentTitle.textContent = ` — ${slides[activeIndex].dataset.title || ""}`;
  };

  const goTo = (index) => {
    activeIndex = (index + slides.length) % slides.length;
    render();
  };

  previous.addEventListener("click", () => {
    goTo(activeIndex - 1);
  });

  next.addEventListener("click", () => {
    goTo(activeIndex + 1);
  });

  carousel.addEventListener("keydown", (event) => {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    event.preventDefault();
    goTo(activeIndex + (event.key === "ArrowRight" ? 1 : -1));
  });

  viewport.addEventListener("pointerdown", (event) => {
    if (event.target.closest("button")) return;
    pointerStart = event.clientX;
    viewport.setPointerCapture(event.pointerId);
  });

  viewport.addEventListener("pointerup", (event) => {
    if (pointerStart === undefined) return;
    const distance = event.clientX - pointerStart;
    pointerStart = undefined;
    if (Math.abs(distance) < 45) return;
    goTo(activeIndex + (distance < 0 ? 1 : -1));
  });

  viewport.addEventListener("pointercancel", () => {
    pointerStart = undefined;
  });

  render();
});
