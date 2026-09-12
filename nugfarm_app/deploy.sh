#!/bin/bash
set -e

echo "==> Build Flutter Web..."
flutter build web --base-href /Nugfarm/

echo "==> Deploy ke GitHub Pages (branch gh-pages)..."
cd build/web
rm -rf .git
git init -q
git add .
git commit -q -m "Deploy update $(date '+%Y-%m-%d %H:%M')"
git branch -M gh-pages
git remote add origin https://github.com/buyapree/Nugfarm.git
git push -q origin gh-pages --force
cd /workspaces/Nugfarm/nugfarm_app

echo "==> Backup kode sumber ke branch main..."
cd /workspaces/Nugfarm
git add .
git commit -q -m "Update $(date '+%Y-%m-%d %H:%M')" || echo "(tidak ada perubahan kode sumber untuk di-commit)"
git push -q origin main
cd /workspaces/Nugfarm/nugfarm_app

echo ""
echo "✅ SELESAI! Cek hasilnya di: https://buyapree.github.io/Nugfarm/"
echo "(kalau belum berubah, tunggu 1-2 menit lalu hard refresh browser)"
