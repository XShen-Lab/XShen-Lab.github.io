/* Manual, accessible story galleries for Blog and the homepage. */
window.addEventListener("DOMContentLoaded", () => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  document.querySelectorAll("[data-blog-flow]").forEach((flow) => {
    const track = flow.querySelector("[data-blog-flow-track]");
    const allSlides = track ? [...track.querySelectorAll(".blog-card")] : [];
    const filters = [...flow.querySelectorAll("[data-blog-filter]")];
    const empty = flow.querySelector("[data-blog-filter-empty]");
    const previous = flow.querySelector("[data-blog-flow-previous]");
    const next = flow.querySelector("[data-blog-flow-next]");
    const progress = flow.querySelector("[data-blog-flow-progress]");
    const status = flow.querySelector("[data-blog-flow-status]");
    if (!track || allSlides.length === 0 || !previous || !next || !progress || !status) return;
    flow.classList.add("is-ready");

    let visibleSlides = [...allSlides];
    let activeIndex = 0;
    let frame = 0;
    let pointerId = null;
    let pointerStart = 0;
    let scrollStart = 0;
    let dragged = false;
    let suppressClick = false;

    const format = (value) => String(value).padStart(2, "0");
    const slideLeft = (index) => visibleSlides[index].offsetLeft - track.offsetLeft;

    const nearestSlideIndex = () => {
      if (visibleSlides.length === 0) return 0;
      return visibleSlides.reduce((closest, slide, index) => {
        const currentDistance = Math.abs(track.scrollLeft - slideLeft(index));
        const closestDistance = Math.abs(track.scrollLeft - slideLeft(closest));
        return currentDistance < closestDistance ? index : closest;
      }, 0);
    };

    const render = () => {
      activeIndex = nearestSlideIndex();
      const total = visibleSlides.length;
      status.textContent = total ? `${format(activeIndex + 1)} / ${format(total)}` : "00 / 00";
      progress.style.transform = `scaleX(${total ? (activeIndex + 1) / total : 0})`;
      previous.disabled = total < 2 || activeIndex === 0;
      next.disabled = total < 2 || activeIndex === total - 1;
      flow.classList.toggle("has-single-slide", total < 2);
      allSlides.forEach((slide) => slide.removeAttribute("aria-current"));
      visibleSlides.forEach((slide, index) => {
        slide.setAttribute("aria-current", String(index === activeIndex));
        slide.setAttribute("aria-label", `${format(index + 1)} / ${format(total)}`);
      });
      frame = 0;
    };

    const scheduleRender = () => {
      if (frame) return;
      frame = window.requestAnimationFrame(render);
    };

    const goTo = (index) => {
      if (visibleSlides.length === 0) return;
      const destination = Math.max(0, Math.min(visibleSlides.length - 1, index));
      track.scrollTo({
        left: slideLeft(destination),
        behavior: reducedMotion.matches ? "auto" : "smooth",
      });
    };

    const applyFilter = (filter, updateAddress = false) => {
      allSlides.forEach((slide) => {
        slide.hidden = filter !== "all" && slide.dataset.blogCategory !== filter;
      });
      visibleSlides = allSlides.filter((slide) => !slide.hidden);
      filters.forEach((button) => button.setAttribute("aria-pressed", String(button.dataset.blogFilter === filter)));
      if (empty) empty.hidden = visibleSlides.length !== 0;
      track.scrollLeft = 0;
      activeIndex = 0;
      render();

      if (updateAddress && window.history.replaceState) {
        const suffix = filter === "all" ? `${window.location.pathname}${window.location.search}` : `#category-${filter}`;
        window.history.replaceState(null, "", suffix);
      }
    };

    filters.forEach((button) => {
      button.addEventListener("click", () => applyFilter(button.dataset.blogFilter, true));
    });

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
      if (event.key === "Home") {
        event.preventDefault();
        goTo(0);
      }
      if (event.key === "End") {
        event.preventDefault();
        goTo(visibleSlides.length - 1);
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

    const initialFilter = window.location.hash.startsWith("#category-")
      ? window.location.hash.replace("#category-", "")
      : "all";
    const matchingFilter = filters.find((button) => button.dataset.blogFilter === initialFilter);
    applyFilter(matchingFilter ? initialFilter : "all");
  });
});
