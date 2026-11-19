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
  ['ecosystem', null, 1200, 900, 'f8f6f1', 0.5],
  ['workflow', null, 1600, 640, 'f8f6f1', 0.5],
  // Industries rows alternate surface / pearl in IndustriesContent order.
  ['industries', 'network', 1300, 1000, 'f8f6f1', 0.5],
  ['industries', 'finance', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'oilgas', 1100, 900, 'f8f6f1', 0.5],
  ['industries', 'logistics', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'ecommerce', 1100, 900, 'f8f6f1', 0.5],
  ['industries', 'healthcare', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'education', 1100, 900, 'f8f6f1', 0.5],
  ['industries', 'realestate', 1100, 900, 'f2eee6', 0.5],
  ['industries', 'hospitality', 1100, 900, 'f8f6f1', 0.5],
];

// Portfolio device stills: each working demo's real screenshot on its
// device, framed tightly and transparent so the card's photograph shows
// through (assets/images/project_devices/<id>.webp). devices.json comes from
// `dart run tool/render_scenes/export_devices.dart`.
const projectDir = path.join(root, 'assets/images/service_projects');
const projectImage = (id) => {
  const file = fs.readdirSync(projectDir).find((f) => f.replace(/\.[^.]+$/, '') === id);
  return `/assets/images/service_projects/${file}`;
};
const devices = JSON.parse(fs.readFileSync(path.join(__dirname, 'devices.json'), 'utf8'));
const screenSpec = (id) => (devices[id].crop ? `${projectImage(id)}#${devices[id].crop}` : projectImage(id));
for (const [id, { device, left }] of Object.entries(devices)) {
  jobs.push(['device', `${device}${left ? '-left' : ''}-plain`, 1600, 900, 'none', 0.5, screenSpec(id), `project_devices/${id}`]);
}
// The Portfolio hero: real demo screenshots on a laptop, phone and tablet.
jobs.push(['device', 'hero', 1400, 1000, 'none', 0.5, ['lumen_dental', 'fitslot', 'weave_and_co'].map(screenSpec).join('|'), 'renders/device_hero']);
// Settings for the AI and automation demos: the gold and platinum AI and
// automation sculptures, composed differently from the service pages.
jobs.push(['ai', null, 1600, 900, '1f1d1b', 0.15, null, 'portfolio/helpdesk_assistant_scene']);
jobs.push(['automation', null, 1600, 900, '1f1d1b', 0.85, null, 'portfolio/flowrunner_scene']);

const types = { '.html': 'text/html', '.js': 'text/javascript', '.jpg': 'image/jpeg', '.png': 'image/png', '.webp': 'image/webp' };

function serve() {
  const server = http.createServer((req, res) => {
    const url = decodeURIComponent(req.url.split('?')[0]);
    const assetsDir = path.join(root, 'assets');
    const file = url === '/stage.html'
      ? path.join(__dirname, 'stage.html')
      : url.startsWith('/assets/') ? path.join(root, url) : path.join(webDir, url);
    if (!file.startsWith(webDir) && !file.startsWith(__dirname) && !file.startsWith(assetsDir)) return res.writeHead(403).end();
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
  // `node render.js workflow industries_ecommerce` renders only those stills.
  const only = process.argv.slice(2);
  for (const [scene, variant, w, h, bg, p, img, out] of jobs) {
    const id = out ? path.basename(out) : null;
    if (only.length && !only.includes(variant ? `${scene}_${variant}` : scene) && !(id && only.includes(id)) && !(out && only.includes('devices'))) continue;
    await page.setViewport({ width: w, height: h, deviceScaleFactor: 1 });
    const query = `s=${scene}&w=${w}&h=${h}&bg=${bg}&p=${p}${variant ? `&variant=${variant}` : ''}${img ? `&img=${encodeURIComponent(img)}` : ''}`;
    await page.goto(`http://localhost:${port}/stage.html?${query}`, { waitUntil: 'load' });
    // Let the scene settle into a natural pose.
    await new Promise((r) => setTimeout(r, 3500));
    const errors = await page.evaluate(() => window.errors);
    const name = out ? id : variant ? `${scene}_${variant}` : scene;
    if (errors.length) {
      failed = true;
      console.error(`${name}: ${errors.join('; ')}`);
      continue;
    }
    const clip = { x: 0, y: 0, width: w, height: h };
    const file = `${out ?? name}.${bg === 'none' ? 'webp' : 'jpg'}`;
    const target = out ? path.join(root, 'assets/images', file) : path.join(outDir, file);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    await page.screenshot(
      bg === 'none'
        ? { path: target, type: 'webp', quality: out ? 80 : 86, omitBackground: true, clip }
        : { path: target, type: 'jpeg', quality: 84, clip },
    );
    console.log(`rendered ${file}`);
  }
  await browser.close();
  server.close();
  process.exitCode = failed ? 1 : 0;
})();
