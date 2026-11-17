// Captures each working demo's window as the 1200×750 screenshot used for its
// project (assets/images/service_projects/<id>.jpg). Run after changing a
// demo's look, against a fresh release build:
//
//   flutter build web --release
//   cd tool/render_scenes && npm run demos            (or: node demos.js fitslot)
const http = require('http');
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer-core');

const root = path.resolve(__dirname, '../..');
const buildDir = path.join(root, 'build/web');
const outDir = path.join(root, 'assets/images/service_projects');
const chrome = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';

// [project id (file name), demo slug]
const jobs = [
  ['lumen_dental', 'clinic-website'],
  ['weave_and_co', 'handloom-store'],
  ['fitslot', 'class-booking-app'],
  ['taskflow', 'responsive-task-board'],
  ['leaddesk_crm', 'mini-crm'],
  ['helpdesk_assistant', 'support-assistant'],
  ['flowrunner', 'enquiry-automation'],
  ['campaign_planner', 'campaign-planner'],
  ['bookly_prototype', 'app-prototype'],
  ['brand_kit_builder', 'brand-kit-builder'],
];

const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.jpg': 'image/jpeg', '.ttf': 'font/ttf', '.otf': 'font/otf',
};

function serve() {
  const server = http.createServer((req, res) => {
    let url = decodeURIComponent(req.url.split('?')[0]);
    if (url === '/') url = '/index.html';
    const file = path.join(buildDir, url);
    if (!file.startsWith(buildDir)) return res.writeHead(403).end();
    fs.readFile(file, (err, data) => {
      if (err) return res.writeHead(404).end();
      res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' }).end(data);
    });
  });
  return new Promise((resolve) => server.listen(0, () => resolve(server)));
}

(async () => {
  if (!fs.existsSync(path.join(buildDir, 'index.html'))) {
    console.error('No build/web — run `flutter build web --release` first.');
    process.exit(1);
  }
  const server = await serve();
  const port = server.address().port;
  const browser = await puppeteer.launch({ executablePath: chrome, headless: 'new' });
  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1100, deviceScaleFactor: 1 });
  const only = process.argv.slice(2);
  let failed = false;
  for (const [id, slug] of jobs) {
    if (only.length && !only.includes(id)) continue;
    await page.goto(`http://localhost:${port}/#/demos/${slug}`, { waitUntil: 'load' });
    await page.waitForFunction(() => !document.getElementById('splash'), { timeout: 30000 });
    await new Promise((r) => setTimeout(r, 2500));
    // Bring the demo window up under the navbar, then find its title bar: the
    // first dark row below the page header, scanned at the window's left edge.
    await page.mouse.move(720, 600);
    await page.mouse.wheel({ deltaY: 380 });
    await new Promise((r) => setTimeout(r, 1500));
    const shot = await page.screenshot({ encoding: 'base64' });
    if (process.env.DEBUG_DIR) fs.writeFileSync(path.join(process.env.DEBUG_DIR, `${id}.png`), Buffer.from(shot, 'base64'));
    const bar = await page.evaluate(async (src) => {
      const img = new Image();
      img.src = 'data:image/png;base64,' + src;
      await img.decode();
      const c = document.createElement('canvas');
      c.width = img.width;
      c.height = img.height;
      const g = c.getContext('2d');
      g.drawImage(img, 0, 0);
      const px = g.getImageData(108, 0, 1, img.height).data;
      const edge = g.getImageData(100, 0, 1, img.height).data; // the window's left border
      let top = -1;
      for (let y = 90; y < img.height; y++) {
        if (px[y * 4] + px[y * 4 + 1] + px[y * 4 + 2] < 200) {
          top = y;
          break;
        }
      }
      if (top < 0) return { top, bottom: -1 };
      // The window ends where its border colour stops (three rows running).
      const ref = (top + 60) * 4;
      const same = (y) => Math.abs(edge[y * 4] - edge[ref]) + Math.abs(edge[y * 4 + 1] - edge[ref + 1]) + Math.abs(edge[y * 4 + 2] - edge[ref + 2]) < 6;
      let bottom = img.height;
      for (let y = top + 60, run = 0; y < img.height; y++) {
        run = same(y) ? 0 : run + 1;
        if (run === 3) {
          bottom = y - 3;
          break;
        }
      }
      return { top, bottom };
    }, shot);
    if (bar.top < 0) {
      failed = true;
      console.error(`${id}: demo window not found`);
      continue;
    }
    // The title bar is 42px tall; the window spans the 1238px content width.
    // A window shorter than 16:10 is centred on a 1200×750 canvas filled with
    // its own background, so neither the page nor the demo gets cut off.
    const top = bar.top + 42;
    const width = 1238;
    const height = Math.min(Math.round((width * 750) / 1200), bar.bottom - top - 6);
    const body = await page.screenshot({ encoding: 'base64', clip: { x: 101, y: top, width, height } });
    const jpeg = await page.evaluate(async (src) => {
      const img = new Image();
      img.src = 'data:image/png;base64,' + src;
      await img.decode();
      const c = document.createElement('canvas');
      c.width = 1200;
      c.height = 750;
      const g = c.getContext('2d');
      const probe = document.createElement('canvas').getContext('2d');
      probe.canvas.width = img.width;
      probe.canvas.height = img.height;
      probe.drawImage(img, 0, 0);
      const [r, gg, b] = probe.getImageData(8, img.height - 4, 1, 1).data;
      g.fillStyle = `rgb(${r},${gg},${b})`;
      g.fillRect(0, 0, 1200, 750);
      const scale = 1200 / img.width;
      const h = img.height * scale;
      g.imageSmoothingQuality = 'high';
      g.drawImage(img, 0, (750 - h) / 2, 1200, h);
      return c.toDataURL('image/jpeg', 0.86).split(',')[1];
    }, body);
    fs.writeFileSync(path.join(outDir, `${id}.jpg`), Buffer.from(jpeg, 'base64'));
    console.log(`captured ${id}.jpg (window body ${width}×${height})`);
  }
  await browser.close();
  server.close();
  process.exitCode = failed ? 1 : 0;
})();
