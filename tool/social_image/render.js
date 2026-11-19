// Renders the 1200 x 630 social sharing image (Open Graph / Twitter card)
// from card.html, which uses the existing charcoal + champagne-gold logo and
// the bundled Sora / Inter fonts. Brand palette only: pearl white, warm
// beige, platinum silver, champagne gold and charcoal; never blue.
//
//   node render.js [output.png]     (default: ../../web/og-image.png)
//   (needs ../render_scenes/node_modules)
const path = require('path');
const puppeteer = require(path.join(__dirname, '../render_scenes/node_modules/puppeteer-core'));

const chrome = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const out = path.resolve(process.argv[2] || path.join(__dirname, '../../web/og-image.png'));

(async () => {
  const browser = await puppeteer.launch({ executablePath: chrome, args: ['--allow-file-access-from-files'] });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1200, height: 630, deviceScaleFactor: 1 });
    await page.goto(`file://${path.join(__dirname, 'card.html').replace(/\\/g, '/')}`, { waitUntil: 'load' });
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({ path: out, type: 'png', clip: { x: 0, y: 0, width: 1200, height: 630 } });
    console.log(`wrote ${out}`);
  } finally {
    await browser.close();
  }
})();
