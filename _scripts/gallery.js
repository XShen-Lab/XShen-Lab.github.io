window.addEventListener("DOMContentLoaded", () => {
  const page = document.querySelector("[data-gallery-page]");
  const dialog = page?.querySelector("[data-gallery-dialog]");
  const works = [...(page?.querySelectorAll("[data-gallery-item]") || [])];

  if (!dialog || works.length === 0 || typeof dialog.showModal !== "function") return;

  const image = dialog.querySelector("[data-gallery-dialog-image]");
  const title = dialog.querySelector("[data-gallery-dialog-title]");
  const caption = dialog.querySelector("[data-gallery-dialog-caption]");
  const source = dialog.querySelector("[data-gallery-dialog-source]");
  const count = dialog.querySelector("[data-gallery-dialog-count]");
  const close = dialog.querySelector("[data-gallery-close]");
  const previous = dialog.querySelector("[data-gallery-previous]");
  const next = dialog.querySelector("[data-gallery-next]");
  let currentIndex = 0;

  const render = (index) => {
    currentIndex = (index + works.length) % works.length;
    const work = works[currentIndex].dataset;
    image.src = work.image;
    image.alt = work.alt;
    title.textContent = work.title;
    caption.textContent = work.caption;
    source.textContent = work.source;
    count.textContent = `${String(currentIndex + 1).padStart(2, "0")} / ${String(works.length).padStart(2, "0")}`;
  };

  works.forEach((work, index) => work.addEventListener("click", () => {
    render(index);
    dialog.showModal();
    close.focus();
  }));

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

  dialog.addEventListener("close", () => works[currentIndex].focus());
});
