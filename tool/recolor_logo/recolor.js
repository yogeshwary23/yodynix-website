// Makes the champagne-gold / platinum variants of the YODYNIX mark.
//
// The original mark is blue and orange. Each pixel keeps its luminance and
// alpha: blue ribbon pixels move onto a platinum-silver ramp and warm
// (orange / yellow / red) pixels onto a champagne-gold ramp, so the ribbon
// shading and highlights survive. The original logo file is never changed.
//
//   node recolor.js <input.png> <output.png>   (needs ../render_scenes/node_modules)
const path = require('path');
const fs = require('fs');
const puppeteer = require(path.join(__dirname, '../render_scenes/node_modules/puppeteer-core'));

const chrome = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';

(async () => {
  const pairs = [];
  for (let i = 2; i + 1 < process.argv.length; i += 2) pairs.push([process.argv[i], process.argv[i + 1]]);
  const browser = await puppeteer.launch({ executablePath: chrome, headless: 'new' });
  const page = await browser.newPage();
  for (const [input, output] of pairs) {
    const src = 'data:image/png;base64,' + fs.readFileSync(input).toString('base64');
    const dataUrl = await page.evaluate(async (src) => {
      const img = new Image();
      img.src = src;
      await img.decode();
      const c = document.createElement('canvas');
      c.width = img.naturalWidth;
      c.height = img.naturalHeight;
      const g = c.getContext('2d');
      g.drawImage(img, 0, 0);
      const data = g.getImageData(0, 0, c.width, c.height);
      const px = data.data;
      // Luminance → colour ramps (dark, mid, light).
      const ramp = (stops, t) => {
        const i = Math.min(stops.length - 2, Math.floor(t * (stops.length - 1)));
        const f = t * (stops.length - 1) - i;
        return stops[i].map((v, k) => v + (stops[i + 1][k] - v) * f);
      };
      const gold = [[58, 42, 18], [122, 90, 40], [198, 164, 106], [233, 213, 168], [255, 248, 230]];
      const platinum = [[46, 44, 41], [104, 100, 94], [176, 172, 165], [226, 223, 217], [255, 255, 253]];
      for (let i = 0; i < px.length; i += 4) {
        if (px[i + 3] === 0) continue;
        const r = px[i] / 255, gg = px[i + 1] / 255, b = px[i + 2] / 255;
        const max = Math.max(r, gg, b), min = Math.min(r, gg, b);
        const lum = 0.2126 * r + 0.7152 * gg + 0.0722 * b;
        const sat = max === 0 ? 0 : (max - min) / max;
        if (sat < 0.12) continue; // white separators and neutral edges stay as they are
        let hue = 0;
        if (max === r) hue = ((gg - b) / (max - min)) % 6;
        else if (max === gg) hue = (b - r) / (max - min) + 2;
        else hue = (r - gg) / (max - min) + 4;
        hue = (hue * 60 + 360) % 360;
        const cool = hue > 150 && hue < 290;
        // Blue is a dark hue; lift it so the platinum reads as polished metal.
        const t = Math.min(1, Math.max(0, cool ? lum * 1.35 + 0.12 : lum * 1.05));
        const [nr, ng, nb] = ramp(cool ? platinum : gold, t);
        px[i] = nr; px[i + 1] = ng; px[i + 2] = nb;
      }
      g.putImageData(data, 0, 0);
      return c.toDataURL('image/png');
    }, src);
    fs.writeFileSync(output, Buffer.from(dataUrl.split(',')[1], 'base64'));
    console.log('wrote', output);
  }
  await browser.close();
})();
