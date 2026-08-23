/* Accessible horizontal flow for the bilingual Blog index. */
window.addEventListener("DOMContentLoaded", () => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  document.querySelectorAll("[data-blog-flow]").forEach((flow) => {
    const track = flow.querySelector("[data-blog-flow-track]");
    const slides = [...track.querySelectorAll(".blog-card")];
    const previous = flow.querySelector("[data-blog-flow-previous]");
    const next = flow.querySelector("[data-blog-flow-next]");
    const progress = flow.querySelector("[data-blog-flow-progress]");
    const status = flow.querySelector("[data-blog-flow-status]");
    if (!track || slides.length === 0) return;

    let activeIndex = 0;
    let frame = 0;
    let pointerId = null;
    let pointerStart = 0;
    let scrollStart = 0;
    let dragged = false;
    let suppressClick = false;

    const format = (value) => String(value).padStart(2, "0");
    const slideLeft = (index) => slides[index].offsetLeft - track.offsetLeft;

    const nearestSlideIndex = () => slides.reduce((closest, slide, index) => {
      const currentDistance = Math.abs(track.scrollLeft - slideLeft(index));
      const closestDistance = Math.abs(track.scrollLeft - slideLeft(closest));
      return currentDistance < closestDistance ? index : closest;
    }, 0);

    const render = () => {
      activeIndex = nearestSlideIndex();
      status.textContent = `${format(activeIndex + 1)} / ${format(slides.length)}`;
      progress.style.transform = `scaleX(${(activeIndex + 1) / slides.length})`;
      previous.disabled = activeIndex === 0;
      next.disabled = activeIndex === slides.length - 1;
      slides.forEach((slide, index) => slide.setAttribute("aria-current", String(index === activeIndex)));
      frame = 0;
    };

    const scheduleRender = () => {
      if (frame) return;
      frame = window.requestAnimationFrame(render);
    };

    const goTo = (index) => {
      const destination = Math.max(0, Math.min(slides.length - 1, index));
      track.scrollTo({
        left: slideLeft(destination),
        behavior: reducedMotion.matches ? "auto" : "smooth",
      });
    };

    previous.addEventListener("click", () => goTo(activeIndex - 1));
    next.addEventListener("click", () => goTo(activeIndex + 1));
    track.addEventListener("scroll", scheduleRender, { passive: true });
    window.addEventListener("resize", scheduleRender, { passive: true });

    track.addEventListener("keydown", (event) => {
      if (event.target !== track) return;
      if (event.key === "ArrowLeft") {
        event.preventDefault();
        goTo(activeIndex - 1);
      }
      if (event.key === "ArrowRight") {
        event.preventDefault();
        goTo(activeIndex + 1);
      }
    });

    track.addEventListener("pointerdown", (event) => {
      if (event.pointerType !== "mouse" || event.button !== 0) return;
      pointerId = event.pointerId;
      pointerStart = event.clientX;
      scrollStart = track.scrollLeft;
      dragged = false;
    });

    track.addEventListener("pointermove", (event) => {
      if (event.pointerId !== pointerId) return;
      const distance = event.clientX - pointerStart;
      if (Math.abs(distance) > 5) {
        if (!dragged) {
          dragged = true;
          track.setPointerCapture(pointerId);
          track.classList.add("is-dragging");
        }
        event.preventDefault();
      }
      if (dragged) track.scrollLeft = scrollStart - distance;
    });

    const finishDrag = (event) => {
      if (event.pointerId !== pointerId) return;
      if (dragged) {
        track.classList.remove("is-dragging");
        if (track.hasPointerCapture(pointerId)) track.releasePointerCapture(pointerId);
        suppressClick = true;
        goTo(nearestSlideIndex());
      }
      pointerId = null;
      window.setTimeout(() => { suppressClick = false; }, 0);
    };

    track.addEventListener("pointerup", finishDrag);
    track.addEventListener("pointercancel", finishDrag);
    track.addEventListener("dragstart", (event) => event.preventDefault());
    track.addEventListener("click", (event) => {
      if (!suppressClick) return;
      event.preventDefault();
      event.stopPropagation();
    }, true);

    render();
  });
});
