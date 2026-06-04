/**
 * Patches all metro-* packages to expose ./src/* exports,
 * required for Node.js 20+ strict exports enforcement compatibility.
 */
const fs = require('fs');
const path = require('path');

const nodeModules = path.join(__dirname, 'node_modules');
const metroPkgs = fs.readdirSync(nodeModules).filter(d => d.startsWith('metro'));

let patched = [];
let skipped = [];

for (const dir of metroPkgs) {
  const pkgPath = path.join(nodeModules, dir, 'package.json');
  try {
    const raw = fs.readFileSync(pkgPath, 'utf8');
    const pkg = JSON.parse(raw);
    if (pkg.exports) {
      let changed = false;
      if (!pkg.exports['./src/*']) {
        pkg.exports['./src/*'] = './src/*.js';
        changed = true;
      }
      if (changed) {
        fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\n');
        patched.push(dir);
      } else {
        skipped.push(dir + ' (already patched)');
      }
    } else {
      skipped.push(dir + ' (no exports field)');
    }
  } catch (e) {
    console.error(`  ERROR patching ${dir}: ${e.message}`);
  }
}

console.log('\n✅ Patched metro packages:');
patched.forEach(p => console.log('  +', p));
if (skipped.length) {
  console.log('\n⏭  Skipped:');
  skipped.forEach(s => console.log('  -', s));
}
console.log('\nDone. Now run: npx expo start --tunnel\n');
