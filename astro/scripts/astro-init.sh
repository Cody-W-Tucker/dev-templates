#!/usr/bin/env bash
set -euo pipefail

# Check if already an Astro project
if [ -f "astro.config.mjs" ] || [ -f "astro.config.ts" ]; then
  echo "Astro project already exists here."
  exit 1
fi

# If directory has files, work around Astro's empty directory requirement
if [ -n "$(ls -A . 2>/dev/null)" ]; then
  echo "Working around Astro's empty directory requirement..."
  
  # Create temp directory inside current directory
  TEMP_DIR=".astro-init-tmp"
  mkdir -p "$TEMP_DIR"
  
  # Run astro create in temp directory
  (cd "$TEMP_DIR" && npm create astro@latest . -- --template minimal --install --typescript strict --skip-houston 2>/dev/null)
  
  # Move everything from temp to current directory
  shopt -s dotglob
  mv "$TEMP_DIR"/* .
  shopt -u dotglob
  
  # Clean up temp directory
  rmdir "$TEMP_DIR"
else
  # Directory is empty, run normally
  npm create astro@latest . -- --template minimal --install --typescript strict --skip-houston 2>/dev/null
fi

npm exec -- astro add tailwind --yes

npm install -D @tailwindcss/typography

node <<'EOF'
const fs = require("fs");
const globalCssPath = "src/styles/global.css";

if (fs.existsSync(globalCssPath)) {
  const pluginLine = "@plugin '@tailwindcss/typography';";
  const css = fs.readFileSync(globalCssPath, "utf8");

  if (!css.includes(pluginLine)) {
    fs.writeFileSync(globalCssPath, `${css.trimEnd()}\n${pluginLine}\n`);
  }
}
EOF

npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-astro prettier prettier-plugin-astro husky lint-staged

cat > eslint.config.mjs << 'EOF'
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import astro from 'eslint-plugin-astro';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  ...astro.configs.recommended,
  { files: ['**/*.astro'], languageOptions: { parser: astro.parser } },
  { rules: {
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'error',
  }},
  { ignores: ['dist/', 'node_modules/', '.astro/'] },
];
EOF

cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "plugins": ["prettier-plugin-astro"],
  "overrides": [{ "files": "*.astro", "options": { "parser": "astro" }}]
}
EOF

cat > .prettierignore << 'EOF'
dist/
node_modules/
.astro/
*.lock
EOF

node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts.lint = "eslint .";
pkg.scripts["lint:fix"] = "eslint . --fix";
pkg.scripts.format = "prettier --write .";
pkg.scripts["format:check"] = "prettier --check .";
pkg.scripts.prepare = "husky";
pkg["lint-staged"] = {
  "*.{js,ts,astro}": ["eslint --fix", "prettier --write"],
  "*.{json,css,md}": ["prettier --write"]
};
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
'

npm exec husky init
cat > .husky/pre-commit << 'EOF'
if command -v lint-staged >/dev/null 2>&1; then
  exec lint-staged
fi

exec nix develop --command npm exec lint-staged
EOF
chmod +x .husky/pre-commit

# Add astro-specific direnv config to .envrc (append if exists, create if not)
if ! grep -q "Auto-install dependencies when entering" .envrc 2>/dev/null; then
  cat >> .envrc << 'EOF'

# Auto-install dependencies when entering the directory
if [ -f package.json ] && [ ! -d node_modules ]; then
  echo "Installing dependencies..."
  npm install
fi

# Show available commands
if [ -f astro.config.mjs ] || [ -f astro.config.ts ]; then
  echo "Astro ready: dev | build | preview | lint | format"
fi
EOF
fi

echo "Astro project ready with Tailwind CSS and agency standards"
