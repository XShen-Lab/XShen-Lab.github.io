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
    await page.goto(base);
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
    assert.equal(await page.locator("[data-gallery-dialog-citation]").getAttribute("href"), "https://doi.org/10.1074/jbc.M413038200");
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
    for (const width of [1440, 768, 390, 320]) {
      await page.setViewportSize({ width, height: 900 });
      for (const route of ["/", "/zh/", "/research/", "/zh/research/", "/gallery/", "/zh/gallery/"]) {
        await page.goto(base + route);
        assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1), `${width}px ${route} overflows`);
        const language = await page.locator("html").getAttribute("lang");
        assert.equal(language, route.startsWith("/zh/") ? "zh-CN" : "en");
        assert.equal(await page.locator(".language-switch").count(), 1);
        assert.equal(await page.locator("img").evaluateAll(images => images.filter(img => img.complete && img.naturalWidth === 0).length), 0, `${route} has broken images`);
      }
    }
    assert.deepEqual(errors, []);
    console.log("PASS: five-second tours, pause/manual controls, reduced motion, Research menu and hash navigation, wardrobe modal and focus, watermarks/citations, 24 bilingual responsive layouts");
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
