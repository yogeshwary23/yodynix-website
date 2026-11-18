// Renders every 3D scene to a JPEG still in assets/images/renders/. The
// stills are what phones, low-power devices and browsers without WebGL see,
// and the service cards use them too, so re-run this after changing a scene.
//
//   cd tool/render_scenes && npm install && npm run render
//
// Set CHROME_PATH if Chrome is not at the default Windows location.
const http = require('http');
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer-core');

const root = path.resolve(__dirname, '../..');
const webDir = path.join(root, 'web');
const outDir = path.join(root, 'assets/images/renders');
const chrome = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';

// [scene, variant, width, height, background, scroll progress]
const jobs = [
  // Backgrounds match the surface each scene sits on: pearl f8f6f1,
  // white ffffff (service cards) or the beige band f2eee6. 'none' renders a
  // transparent WebP for scenes drawn over a painted backdrop (the hero).
  ['hero', null, 1300, 1000, 'none', 0.0],
  ['web', null, 1200, 800, 'ffffff', 0.5],
  ['web', 'shop', 1200, 800, 'ffffff', 0.5],
  ['mobile', null, 1200, 800, 'ffffff', 0.5],
  ['mobile', 'single', 1200, 800, 'ffffff', 0.5],
  ['ai', null, 1200, 800, 'ffffff', 0.5],
  ['software', null, 1200, 800, 'ffffff', 0.5],
  ['software', 'design', 1200, 800, 'ffffff', 0.5],
  ['automation', null, 1200, 800, 'ffffff', 0.5],
  ['marketing', null, 1200, 800, 'ffffff', 0.6],
  ['marketing', 'brand', 1200, 800, 'ffffff', 0.6],
  ['about', null, 1188, 1100, 'none', 0.5],
  ['aboutPage', 'who', 1188, 1100, 'none', 0.5],
  ['aboutPage', 'team', 1188, 1100, 'none', 0.5],
  ['aboutPage', 'philosophy', 1188, 1100, 'none', 0.5],
  ['aboutPage', 'process', 1188, 1100, 'none', 0.5],
  // 3D overlays for the core pillar cards, composited over their photos
  // (stills only; no live scene on the cards).
  ['overlay', 'business', 1200, 750, 'none', 0.5],
  ['overlay', 'innovation', 1200, 750, 'none', 0.5],
  ['overlay', 'careers', 1200, 750, 'none', 0.5],
  ['neural', null, 1600, 760, 'f8f6f1', 0.5],
  ['ecosystem', null, 1200, 900, 'f8f6f1', 0.5],
  ['workflow', null, 1600, 640, 'f8f6f1', 0.5],
  ['network', null, 1600, 560, 'f2eee6', 0.5],
  ['industries', 'finance', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'healthcare', 1100, 900, 'f8f6f1', 0.5],
  ['industries', 'retail', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'education', 1100, 900, 'f8f6f1', 0.5],
  ['industries', 'realestate', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'hospitality', 1100, 900, 'f8f6f1', 0.5],
];

const types = { '.html': 'text/html', '.js': 'text/javascript' };

function serve() {
  const server = http.createServer((req, res) => {
    const url = decodeURIComponent(req.url.split('?')[0]);
    const file = url === '/stage.html' ? path.join(__dirname, 'stage.html') : path.join(webDir, url);
    if (!file.startsWith(webDir) && !file.startsWith(__dirname)) return res.writeHead(403).end();
    fs.readFile(file, (err, data) => {
      if (err) return res.writeHead(404).end();
      res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' }).end(data);
    });
  });
  return new Promise((resolve) => server.listen(0, () => resolve(server)));
}

(async () => {
  const server = await serve();
  const port = server.address().port;
  const browser = await puppeteer.launch({
    executablePath: chrome,
    headless: 'new',
    args: ['--use-angle=d3d11', '--enable-gpu', '--ignore-gpu-blocklist'],
  });
  const page = await browser.newPage();
  let failed = false;
  // `node render.js workflow industries_retail` renders only those stills.
  const only = process.argv.slice(2);
  for (const [scene, variant, w, h, bg, p] of jobs) {
    if (only.length && !only.includes(variant ? `${scene}_${variant}` : scene)) continue;
    await page.setViewport({ width: w, height: h, deviceScaleFactor: 1 });
    const query = `s=${scene}&w=${w}&h=${h}&bg=${bg}&p=${p}${variant ? `&variant=${variant}` : ''}`;
    await page.goto(`http://localhost:${port}/stage.html?${query}`, { waitUntil: 'load' });
    // Let the scene settle into a natural pose.
    await new Promise((r) => setTimeout(r, 3500));
    const errors = await page.evaluate(() => window.errors);
    const name = variant ? `${scene}_${variant}` : scene;
    if (errors.length) {
      failed = true;
      console.error(`${name}: ${errors.join('; ')}`);
      continue;
    }
    const clip = { x: 0, y: 0, width: w, height: h };
    const file = bg === 'none' ? `${name}.webp` : `${name}.jpg`;
    await page.screenshot(
      bg === 'none'
        ? { path: path.join(outDir, file), type: 'webp', quality: 86, omitBackground: true, clip }
        : { path: path.join(outDir, file), type: 'jpeg', quality: 84, clip },
    );
    console.log(`rendered ${file}`);
  }
  await browser.close();
  server.close();
  process.exitCode = failed ? 1 : 0;
})();
