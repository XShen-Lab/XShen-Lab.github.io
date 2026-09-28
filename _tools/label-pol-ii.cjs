// Set the generated conceptual artwork's annotations in the supplied Arial Bold font.
// Usage: node _tools/label-pol-ii.cjs source.png /absolute/path/to/Arial\ Bold.ttf
const fs = require("node:fs");
const path = require("node:path");
const sharp = require("sharp");
const [source, fontfile] = process.argv.slice(2);
if (!source || !fontfile || !fs.existsSync(fontfile)) throw new Error("Supply the original artwork and Arial Bold font");
const labels = [
  ["RPB1", 301, 505, 150, 58], ["RPB2", 763, 595, 151, 58],
  ["RPB3", 211, 1019, 149, 51], ["RPB4", 1110, 216, 137, 47],
  ["RPB5", 26, 780, 126, 49], ["RPB6", 62, 194, 125, 50],
  ["RPB7", 1110, 476, 137, 50], ["RPB8", 1110, 763, 137, 51],
  ["RPB9", 497, 73, 140, 49], ["RPB10", 728, 1091, 156, 50],
  ["RPB11", 476, 1101, 159, 50], ["RPB12", 968, 988, 151, 50],
];
(async () => {
  const metadata = await sharp(source).metadata();
  if (metadata.width !== 1254 || metadata.height !== 1254) throw new Error("Annotation coordinates require the original 1254px artwork");
  const background = Buffer.from(`<svg width="1254" height="1254">${labels.map(([,x,y,w,h]) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="5" fill="white"/>`).join("")}</svg>`);
  const layers = [{ input: background }];
  for (const [label, x, y, w, h] of labels) {
    const { data, info } = await sharp({ text: { text: label, font: "Arial Bold 40", fontfile, rgba: true } }).png().toBuffer({ resolveWithObject: true });
    layers.push({ input: data, left: x + Math.round((w - info.width) / 2), top: y + Math.round((h - info.height) / 2) });
  }
  await sharp(source).composite(layers).webp({ quality: 92 }).toFile(path.join(__dirname, "../images/home/information-flow/pol-ii-subunits.webp"));
})().catch(error => { console.error(error); process.exitCode = 1; });
