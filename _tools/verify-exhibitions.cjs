// Run against a locally served production build. Uses the existing Playwright runtime.
const assert = require("node:assert/strict");
const { chromium } = require("playwright");
const base = process.env.SITE_URL || "http://127.0.0.1:4181";

(async () => {
  const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROME_PATH || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" });
  try {
    const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
    const errors = [];
    page.on("pageerror", error => errors.push(error.message));
    await page.goto(base, { waitUntil: "domcontentloaded" });
    await page.mouse.move(0, 0);
    const index = () => page.locator("[data-hero-carousel-current]").textContent();
    assert.equal(await index(), "01");
    await page.waitForTimeout(5300);
    assert.equal(await index(), "02", "home advances after five seconds");
    await page.locator("[data-hero-carousel] [data-autoplay-toggle]").click();
    await page.mouse.move(0, 0);
    await page.waitForTimeout(5300);
    assert.equal(await index(), "02", "pause persists after pointer leaves");
    await page.locator("[data-hero-carousel-next]").click();
    assert.equal(await index(), "03", "manual controls remain available");
    await page.locator("[data-research-menu] summary").click();
    await page.locator('[data-research-menu] a[href="/research/#cell-fate-dynamics"]').click();
    await page.waitForURL("**/research/#cell-fate-dynamics");
    assert.equal(await page.locator("[data-research-position]").textContent(), "04");
    assert.equal(await page.locator(".research-technology__list strong").allTextContents().then(a => a.join("|")), "Molecular|Spatial|Perturbation|Biochemical reconstitution|Modeling");
    assert.equal(await page.locator('.research-program.motif-field img[src*="watermarked"]').count(), 0);
    assert.equal(await page.locator('.research-program.motif-checkpoint img[src*="watermarked"]').count(), 3);
    assert.equal(await page.locator('.research-program.motif-field .figure-source a').count(), 4);
    await page.mouse.move(0, 0);
    await page.waitForTimeout(5700);
    assert.equal(await page.locator("[data-research-position]").textContent(), "01", "Research loops back to the first program");

    await page.goto(base + "/blog/");
    await page.locator("[data-blog-flow-track]").scrollIntoViewIfNeeded();
    await page.mouse.move(0, 0);
    await page.waitForTimeout(5700);
    assert.match(await page.locator("[data-blog-flow-status]").textContent(), /^02/);
    await page.locator('[data-blog-filter="recruitment"]').click();
    assert.match(await page.locator("[data-blog-flow-status]").textContent(), /01 \/ 01/);
    await page.mouse.move(0, 0);
    await page.waitForTimeout(5300);
    assert.match(await page.locator("[data-blog-flow-status]").textContent(), /01 \/ 01/, "single-story filters remain stable");

    await page.goto(base + "/gallery/");
    await page.locator("[data-gallery-door]").click();
    await page.locator("[data-gallery-dialog][open]").waitFor();
    await page.mouse.move(0, 0);
    assert.equal(await page.locator("[data-gallery-dialog-title]").textContent(), "RNA Polymerase II");
    assert.equal(await page.locator("[data-gallery-dialog-citation] a").count(), 0, "original Pol II illustration has no paper attribution");
    await page.waitForTimeout(5500);
    assert.match(await page.locator("[data-gallery-dialog-count]").textContent(), /^02/);
    await page.keyboard.press("Escape");
    assert.equal(await page.locator("[data-gallery-door]").evaluate(el => el === document.activeElement), true);

    await page.goto(base + "/team/");
    const members = page.locator("[data-member-gallery]").first();
    await members.scrollIntoViewIfNeeded();
    await page.mouse.move(0, 0);
    const initial = await members.locator("[data-gallery-track]").evaluate(el => el.scrollLeft);
    await page.waitForTimeout(5500);
    assert.ok(await members.locator("[data-gallery-track]").evaluate(el => el.scrollLeft) > initial, "member cards advance automatically");

    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto(base);
    assert.equal(await page.locator("[data-hero-carousel] [data-autoplay-toggle]").getAttribute("aria-pressed"), "false");
    for (const width of [1920, 1440, 768, 390, 320]) {
      await page.setViewportSize({ width, height: 900 });
      for (const route of ["/", "/zh/", "/research/", "/zh/research/", "/gallery/", "/zh/gallery/", "/team/", "/zh/people/", "/publications/", "/zh/publications/", "/contact/", "/zh/contact/", "/join-us/", "/zh/join-us/"]) {
        assert.equal((await page.goto(base + route)).status(), 200, `${route} loads`);
        await page.evaluate(() => document.fonts.ready);
        assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1), `${width}px ${route} overflows`);
        const language = await page.locator("html").getAttribute("lang");
        assert.equal(language, route.startsWith("/zh/") ? "zh-CN" : "en");
        assert.equal(await page.locator(".language-switch").count(), 1);
        assert.equal(await page.locator("img").evaluateAll(images => images.filter(img => img.complete && img.naturalWidth === 0).length), 0, `${route} has broken images`);
        assert.equal(await page.locator('a[href="https://doi.org/10.1074/jbc.M413038200"]').count(), 0, "Pol II citation is not displayed");
        assert.equal(await page.locator('img[src*="transcription-dichotomy-watermarked"], img[src*="information-flow-framework-watermarked"], img[src*="surveillance-core-watermarked"], img[src*="chromatin-rnp-mesh-watermarked"]').count(), 0, "specified concept images have no watermark");
        if (route.endsWith("/research/")) {
          assert.equal(await page.locator(".research-ctd-panel img").count(), 4);
          const columns = await page.locator(".research-ctd-panels").evaluate(el => getComputedStyle(el).gridTemplateColumns.split(" ").length);
          assert.equal(columns, width <= 700 ? 1 : 2, "CTD panels use separate phone and desktop layouts");
          const shell = await page.locator(".research-shell").first().boundingBox();
          assert.ok(shell.x <= Math.max(40, (width - 1520) / 2) + 1, "reduced Research page margins");
        }
        if (route === "/" || route === "/zh/") {
          const columns = await page.locator(".rna-research-grid").evaluate(el => getComputedStyle(el).gridTemplateColumns.split(" ").length);
          assert.equal(columns, width <= 700 ? 1 : 12, "home research cards stack on phones");
        }
      }
    }
    assert.deepEqual(errors, []);
    console.log("PASS: five-second tours, pause/manual controls, reduced motion, Research menu and hash navigation, wardrobe modal and focus, concept/source policies, four CTD panels, 70 bilingual responsive layouts");
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
