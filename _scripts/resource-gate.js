/* Session-scoped access gate for the bilingual Resources pages. */
window.addEventListener("DOMContentLoaded", () => {
  const storageKey = "xshen-resource-access-v1";
  const expectedDigest = "debc902b1a8eb4a86e06b576836b184381267742a37f14e552f8a17de0c02751";
  const root = document.documentElement;
  const chinese = root.lang === "zh-CN";

  const hasAccess = () => {
    try {
      return window.sessionStorage.getItem(storageKey) === "granted";
    } catch (error) {
      return false;
    }
  };

  const storeAccess = (granted) => {
    try {
      if (granted) window.sessionStorage.setItem(storageKey, "granted");
      else window.sessionStorage.removeItem(storageKey);
    } catch (error) {
      // The gate still works for the current page when storage is unavailable.
    }
  };

  const applyAccessState = (granted) => {
    root.classList.toggle("resource-access-granted", granted);

    document.querySelectorAll("[data-resource-nav-link]").forEach((link) => {
      const label = link.dataset.resourceLabel;
      link.setAttribute("aria-label", chinese
        ? `${label}，${granted ? "已解锁" : "已锁定"}`
        : `${label}, ${granted ? "unlocked" : "locked"}`);
    });

    document.querySelectorAll("[data-resource-access]").forEach((access) => {
      const panel = access.querySelector("[data-resource-gate-panel]");
      const content = access.querySelector("[data-resource-content]");
      if (panel) panel.hidden = granted;
      if (content) content.hidden = !granted;
    });
  };

  const digest = async (value) => {
    const bytes = new TextEncoder().encode(value);
    const hash = await window.crypto.subtle.digest("SHA-256", bytes);
    return [...new Uint8Array(hash)]
      .map((byte) => byte.toString(16).padStart(2, "0"))
      .join("");
  };

  applyAccessState(hasAccess());

  document.querySelectorAll("[data-resource-form]").forEach((form) => {
    const input = form.querySelector("[data-resource-password]");
    const submit = form.querySelector("[data-resource-submit]");
    const error = form.querySelector("[data-resource-error]");

    input.addEventListener("input", () => {
      input.removeAttribute("aria-invalid");
      error.hidden = true;
      form.classList.remove("is-invalid");
    });

    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      if (!input.value) {
        input.focus();
        return;
      }

      submit.disabled = true;
      try {
        const valid = await digest(input.value) === expectedDigest;
        input.value = "";

        if (valid) {
          storeAccess(true);
          applyAccessState(true);
          const contentHeading = document.querySelector("[data-resource-content] h1");
          if (contentHeading) {
            contentHeading.setAttribute("tabindex", "-1");
            contentHeading.focus({ preventScroll: true });
          }
          return;
        }

        input.setAttribute("aria-invalid", "true");
        error.hidden = false;
        form.classList.remove("is-invalid");
        window.requestAnimationFrame(() => form.classList.add("is-invalid"));
        input.focus();
      } catch (verificationError) {
        error.textContent = chinese
          ? "当前浏览器无法完成密码验证。"
          : "This browser could not complete password verification.";
        error.hidden = false;
      } finally {
        submit.disabled = false;
      }
    });
  });

  document.querySelectorAll("[data-resource-relock]").forEach((button) => {
    button.addEventListener("click", () => {
      storeAccess(false);
      applyAccessState(false);
      const input = document.querySelector("[data-resource-password]");
      if (input) input.focus();
    });
  });
});
