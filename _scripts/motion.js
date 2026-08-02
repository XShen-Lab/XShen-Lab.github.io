/* Lightweight viewport and information-flow motion for the XShen Lab site. */
document.documentElement.classList.add("js");

window.addEventListener("DOMContentLoaded", () => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const header = document.querySelector("[data-site-header]");
  const progress = document.querySelector("[data-site-progress]");
  const navToggle = document.querySelector("#site-nav-toggle");
  const nav = document.querySelector("#site-nav");
  const reveals = [...document.querySelectorAll("[data-reveal]")];
  const heroReveals = [...document.querySelectorAll(".rna-hero [data-reveal]")];
  const story = document.querySelector("[data-rna-story]");
  const stages = [...document.querySelectorAll("[data-flow-stage]")];
  const scaleSection = document.querySelector(".rna-methods");
  const hero = document.querySelector(".rna-hero");

  const setVisible = () => reveals.forEach((element) => element.classList.add("is-visible"));
  heroReveals.forEach((element) => element.classList.add("is-visible"));

  if (reducedMotion.matches || !("IntersectionObserver" in window)) {
    setVisible();
    stages.forEach((stage) => stage.classList.add("is-active"));
  } else {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -9%", threshold: 0.08 });
    reveals.filter((element) => !heroReveals.includes(element)).forEach((element) => revealObserver.observe(element));

    const stageObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) entry.target.classList.add("is-active");
        else entry.target.classList.remove("is-active");
      });
    }, { rootMargin: "-25% 0px -35%", threshold: 0.18 });
    stages.forEach((stage) => stageObserver.observe(stage));

    if (hero) {
      const heroObserver = new IntersectionObserver(([entry]) => {
        hero.classList.toggle("motion-paused", !entry.isIntersecting);
      }, { threshold: 0.01 });
      heroObserver.observe(hero);
    }
  }

  const setNavExpanded = (expanded) => {
    if (!navToggle) return;
    navToggle.checked = expanded;
    navToggle.setAttribute("aria-expanded", String(expanded));
  };

  if (navToggle && nav) {
    navToggle.addEventListener("change", () => setNavExpanded(navToggle.checked));
    nav.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => setNavExpanded(false)));
    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && navToggle.checked) {
        setNavExpanded(false);
        navToggle.focus();
      }
    });
  }

  let scheduled = false;
  const clamp = (value) => Math.min(1, Math.max(0, value));
  const elementProgress = (element) => {
    if (!element) return 0;
    const rect = element.getBoundingClientRect();
    const travel = rect.height + window.innerHeight;
    return clamp((window.innerHeight - rect.top) / travel);
  };

  const updateScrollState = () => {
    const scrollable = document.documentElement.scrollHeight - window.innerHeight;
    const pageProgress = scrollable > 0 ? window.scrollY / scrollable : 0;
    if (progress) progress.style.transform = `scaleX(${clamp(pageProgress)})`;
    if (header) header.classList.toggle("is-scrolled", window.scrollY > 18);
    if (story) story.style.setProperty("--story-progress", elementProgress(story));
    if (scaleSection) scaleSection.style.setProperty("--scale-progress", elementProgress(scaleSection));
    scheduled = false;
  };

  const scheduleScrollUpdate = () => {
    if (scheduled) return;
    scheduled = true;
    window.requestAnimationFrame(updateScrollState);
  };

  updateScrollState();
  window.addEventListener("scroll", scheduleScrollUpdate, { passive: true });
  window.addEventListener("resize", scheduleScrollUpdate, { passive: true });
});
