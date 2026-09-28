window.addEventListener("DOMContentLoaded", () => {
  const page = document.querySelector("[data-gallery-page]");
  const dialog = page?.querySelector("[data-gallery-dialog]");
  const works = [...(page?.querySelectorAll("[data-gallery-item]") || [])];

  if (!dialog || works.length === 0 || typeof dialog.showModal !== "function") return;

  const image = dialog.querySelector("[data-gallery-dialog-image]");
  const title = dialog.querySelector("[data-gallery-dialog-title]");
  const caption = dialog.querySelector("[data-gallery-dialog-caption]");
  const source = dialog.querySelector("[data-gallery-dialog-source]");
  const citation = dialog.querySelector("[data-gallery-dialog-citation]");
  const count = dialog.querySelector("[data-gallery-dialog-count]");
  const close = dialog.querySelector("[data-gallery-close]");
  const previous = dialog.querySelector("[data-gallery-previous]");
  const next = dialog.querySelector("[data-gallery-next]");
  let currentIndex = 0;
  let opener;

  const render = (index) => {
    currentIndex = (index + works.length) % works.length;
    const work = works[currentIndex].dataset;
    image.src = work.image;
    if (!window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      image.animate([{ opacity: 0, transform: "translateX(12px)" }, { opacity: 1, transform: "translateX(0)" }], { duration: 650, easing: "ease-out" });
    }
    image.alt = work.alt;
    title.textContent = work.title;
    caption.textContent = work.caption;
    source.textContent = work.source;
    citation.hidden = !work.citationUrl;
    if (work.citationUrl) {
      citation.href = work.citationUrl;
      citation.textContent = work.citationTitle;
    } else {
      citation.removeAttribute("href");
      citation.textContent = "";
    }
    count.textContent = `${String(currentIndex + 1).padStart(2, "0")} / ${String(works.length).padStart(2, "0")}`;
    const upcoming = new Image();
    upcoming.src = works[(currentIndex + 1) % works.length].dataset.image;
  };

  works.forEach((work, index) => work.addEventListener("click", () => {
    opener = work;
    render(index);
    dialog.showModal();
    close.focus();
  }));

  const door = page.querySelector("[data-gallery-door]");
  door?.addEventListener("click", () => {
    opener = door;
    door.classList.add("is-open");
    window.setTimeout(() => {
      render(0);
      dialog.showModal();
      close.focus();
    }, window.matchMedia("(prefers-reduced-motion: reduce)").matches ? 0 : 750);
  });

  window.createExhibitAutoplay(dialog.querySelector(".gallery-viewer__stage"), () => render(currentIndex + 1), {
    canAdvance: () => dialog.open,
  });

  close.addEventListener("click", () => dialog.close());
  previous.addEventListener("click", () => render(currentIndex - 1));
  next.addEventListener("click", () => render(currentIndex + 1));

  dialog.addEventListener("click", (event) => {
    if (event.target === dialog) dialog.close();
  });

  dialog.addEventListener("keydown", (event) => {
    if (event.key === "ArrowLeft") {
      event.preventDefault();
      render(currentIndex - 1);
    }
    if (event.key === "ArrowRight") {
      event.preventDefault();
      render(currentIndex + 1);
    }
  });

  dialog.addEventListener("close", () => {
    door?.classList.remove("is-open");
    opener?.focus();
  });
});
