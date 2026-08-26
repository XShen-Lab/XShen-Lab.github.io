(() => {
  const browsers = document.querySelectorAll("[data-publication-browser]");

  browsers.forEach((browser) => {
    const dataElement = browser.querySelector("[data-publication-records]");
    const list = browser.querySelector(".full-publications");
    const status = browser.querySelector("[data-publication-status]");
    const empty = browser.querySelector("[data-publication-empty]");
    const yearButtons = [...browser.querySelectorAll("[data-publication-year]")];
    const categoryButtons = [...browser.querySelectorAll("[data-publication-category]")];
    if (!dataElement || !list || !status || !empty) return;

    let records;
    try {
      records = JSON.parse(dataElement.textContent);
    } catch (_error) {
      return;
    }

    const items = [...list.children];
    if (items.length !== records.length) return;

    const validYears = new Set(yearButtons.map((button) => button.dataset.publicationYear));
    const validCategories = new Set(categoryButtons.map((button) => button.dataset.publicationCategory));
    const url = new URL(window.location.href);
    let selectedYear = validYears.has(url.searchParams.get("year")) ? url.searchParams.get("year") : "all";
    let selectedCategory = validCategories.has(url.searchParams.get("category")) ? url.searchParams.get("category") : "all";

    records.forEach((record, index) => {
      const item = items[index];
      item.dataset.publicationId = record.id;
      item.dataset.publicationYear = String(record.year);
      item.dataset.publicationCategory = record.category;
    });

    browser.dataset.enhanced = "true";

    const matchesYear = (record, year) => year === "all" || String(record.year) === year;
    const matchesCategory = (record, category) => category === "all" || record.category === category;
    const setPressed = (buttons, dataName, selected) => {
      buttons.forEach((button) => {
        const active = button.dataset[dataName] === selected;
        button.setAttribute("aria-pressed", String(active));
      });
    };

    const setCounts = () => {
      yearButtons.forEach((button) => {
        const year = button.dataset.publicationYear;
        const count = records.filter((record) => matchesYear(record, year) && matchesCategory(record, selectedCategory)).length;
        button.querySelector("[data-filter-count]").textContent = count;
      });

      categoryButtons.forEach((button) => {
        const category = button.dataset.publicationCategory;
        const count = records.filter((record) => matchesYear(record, selectedYear) && matchesCategory(record, category)).length;
        button.querySelector("[data-filter-count]").textContent = count;
      });
    };

    const updateUrl = () => {
      const nextUrl = new URL(window.location.href);
      if (selectedYear === "all") nextUrl.searchParams.delete("year");
      else nextUrl.searchParams.set("year", selectedYear);
      if (selectedCategory === "all") nextUrl.searchParams.delete("category");
      else nextUrl.searchParams.set("category", selectedCategory);
      window.history.replaceState({}, "", nextUrl);
    };

    const render = () => {
      let visibleCount = 0;
      records.forEach((record, index) => {
        const visible = matchesYear(record, selectedYear) && matchesCategory(record, selectedCategory);
        items[index].hidden = !visible;
        if (visible) visibleCount += 1;
      });

      setPressed(yearButtons, "publicationYear", selectedYear);
      setPressed(categoryButtons, "publicationCategory", selectedCategory);
      setCounts();
      status.textContent = browser.dataset.resultsTemplate.replace("COUNT", visibleCount);
      empty.hidden = visibleCount !== 0;
      list.hidden = visibleCount === 0;
      updateUrl();
    };

    yearButtons.forEach((button) => {
      button.addEventListener("click", () => {
        selectedYear = button.dataset.publicationYear;
        render();
      });
    });

    categoryButtons.forEach((button) => {
      button.addEventListener("click", () => {
        selectedCategory = button.dataset.publicationCategory;
        render();
      });
    });

    render();
  });
})();
