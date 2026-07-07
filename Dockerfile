FROM n8nio/n8n:latest

# Patch origin-validator to allow connections when Origin header is stripped by
# Render's reverse proxy on WebSocket/SSE upgrade requests.
# Authentication is still enforced by the JWT auth middleware.
USER root
RUN node -e " \
  const fs = require('fs'); \
  const path = '/usr/local/lib/node_modules/n8n/dist/push/origin-validator.js'; \
  let src = fs.readFileSync(path, 'utf8'); \
  const before = 'const originInfo = parseOrigin(headers.origin ?? \\'\\');'; \
  const after = 'if (headers.origin === undefined) { return { isValid: true }; }\n' + before; \
  if (!src.includes(before)) { console.error('Patch failed: pattern not found'); process.exit(1); } \
  fs.writeFileSync(path, src.replace(before, after)); \
  console.log('origin-validator.js patched OK'); \
"
USER node
