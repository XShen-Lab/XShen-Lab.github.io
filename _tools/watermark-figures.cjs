// Reproducible, pixel-preserving text overlay; originals remain untouched.
// NODE_PATH must expose sharp; Ruby/YAML comes from the Jekyll toolchain.
// Usage: node _tools/watermark-figures.cjs /absolute/path/to/Arial.ttf [/images/selected.png ...]
const fs = require("node:fs");
const path = require("node:path");
const sharp = require("sharp");
const { execFileSync } = require("node:child_process");
const root = path.resolve(__dirname, "..");
const fontfile = process.argv[2];
const selected = new Set(process.argv.slice(3));
if (!fontfile || !fs.existsSync(fontfile)) throw new Error("Supply an existing Arial font file");
const sources = JSON.parse(execFileSync("ruby", ["-ryaml", "-rjson", "-e", "puts YAML.load_file(ARGV[0]).to_json", path.join(root, "_data/figure_sources.yml")], { encoding: "utf8" }));

(async () => {
  for (const [asset, source] of Object.entries(sources)) {
    if (source.status !== "unpublished") continue;
    if (selected.size && !selected.has(asset)) continue;
    const input = path.join(root, asset);
    const output = input.replace(/\.(\w+)$/, "-watermarked.$1");
    const { width, height } = await sharp(input).metadata();
    if (source.watermark === "footer") {
      // Keep every data pixel, axis and legend intact; identify status in a new footer.
      const footerHeight = Math.round(width * 0.03);
      const { data, info } = await sharp({ text: {
        text: '<span foreground="#66665d">XShen Lab · Unpublished</span>',
        font: `Arial ${Math.round(width * 0.016)}`, fontfile, rgba: true,
      } }).png().toBuffer({ resolveWithObject: true });
      await sharp(input).extend({ bottom: footerHeight, background: "white" })
        .composite([{ input: data, left: Math.round(width * 0.012), top: height + Math.round((footerHeight - info.height) / 2) }]).toFile(output);
      console.log(path.relative(root, output));
      continue;
    }
    const fontSize = Math.max(13, Math.round(width * 0.032));
    const { data: mark, info } = await sharp({ text: {
      text: '<span foreground="#ffffff" alpha="90%">XShen Lab · Unpublished</span>',
      font: `Arial ${fontSize}`, fontfile, rgba: true,
    } }).png().toBuffer({ resolveWithObject: true });
    const overlays = [0.32, 0.76].map(fraction => ({
      input: mark,
      top: Math.min(height - info.height, Math.round(height * fraction)),
      left: Math.max(0, Math.round((width - info.width) / 2)),
    }));
    // A translucent backing keeps labels readable on microscopy and white diagrams.
    const backing = Buffer.from(`<svg width="${width}" height="${height}"><g fill="#252520" fill-opacity=".48">${overlays.map(o => `<rect x="${o.left - 4}" y="${o.top - 3}" width="${info.width + 8}" height="${info.height + 6}" rx="3"/>`).join("")}</g></svg>`);
    await sharp(input).composite([{ input: backing }, ...overlays]).toFile(output);
    if (asset.endsWith(".jpg")) {
      for (const size of [480, 960]) {
        if (width < size) continue;
        await sharp(output).resize({ width: size, withoutEnlargement: true }).webp({ quality: 88 }).toFile(output.replace(/\.jpg$/, `-${size}.webp`));
      }
    }
    console.log(path.relative(root, output));
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
