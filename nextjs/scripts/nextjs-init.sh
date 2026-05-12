#!/usr/bin/env bash
set -euo pipefail

if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
  echo "Next.js project already exists here."
  exit 1
fi

if [ -n "$(ls -A . 2>/dev/null)" ]; then
  echo "Working around create-next-app's empty directory requirement..."

  TEMP_DIR="nextjs-init-tmp"
  mkdir -p "$TEMP_DIR"

  npm create next-app@latest "$TEMP_DIR" -- \
    --ts \
    --tailwind \
    --eslint \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --disable-git \
    --use-npm \
    --yes

  shopt -s dotglob
  mv "$TEMP_DIR"/* .
  shopt -u dotglob

  rmdir "$TEMP_DIR"
else
  npm create next-app@latest . -- \
    --ts \
    --tailwind \
    --eslint \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --disable-git \
    --use-npm \
    --yes
fi

cat > AGENTS.md << 'EOF'
<!-- BEGIN:nextjs-agent-rules -->

# Next.js: ALWAYS read docs before coding

Before any Next.js work, find and read the relevant doc in `node_modules/next/dist/docs/`. Your training data is outdated; the docs are the source of truth.

<!-- END:nextjs-agent-rules -->
EOF

cat > CLAUDE.md << 'EOF'
@AGENTS.md
EOF

cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
EOF

cat > .prettierignore << 'EOF'
.next/
node_modules/
out/
*.lock
EOF

node <<'EOF'
const fs = require("fs");

const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts.format = "prettier --write .";
pkg.scripts["format:check"] = "prettier --check .";
pkg.scripts.vercel = "npx vercel@latest";
pkg.scripts.prepare = "husky";
pkg.overrides = {
  ...(pkg.overrides || {}),
  postcss: "8.5.14"
};
pkg["lint-staged"] = {
  "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,css,md}": ["prettier --write"]
};

fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
EOF

npm install -D prettier husky lint-staged --ignore-scripts

mkdir -p .husky
cat > .husky/pre-commit << 'EOF'
if command -v lint-staged >/dev/null 2>&1; then
  exec lint-staged
fi

exec nix develop --command npm exec lint-staged
EOF
chmod +x .husky/pre-commit

if ! grep -q "Auto-install dependencies when entering" .envrc 2>/dev/null; then
  cat >> .envrc << 'EOF'

# Auto-install dependencies when entering the directory
if [ -f package.json ] && [ ! -d node_modules ]; then
  echo "Installing dependencies..."
  npm install
fi

# Show available commands
if [ -f next.config.js ] || [ -f next.config.mjs ] || [ -f next.config.ts ]; then
  echo "Next.js ready: dev | build | start | lint | format"
fi
EOF
fi

echo "Next.js project ready with TypeScript, Tailwind CSS, ESLint, and Prettier"
