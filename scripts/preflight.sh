#!/bin/bash
# Pre-flight: Vercel + Neon setup (personal tier)
set -euo pipefail

APP_NAME="carrd-clone"

echo "=== Pre-flight Setup (Vercel + Neon) ==="
echo ""

# 1. Neon database
echo "--- Neon Database ---"
echo "Create a free Postgres database at https://neon.tech"
echo "Then copy the connection string into .env as DATABASE_URL."
echo ""
if ! grep -q '^DATABASE_URL=' .env 2>/dev/null; then
  echo "ERROR: DATABASE_URL not set in .env. Add your Neon connection string first."
  echo "  Example: DATABASE_URL=postgresql://user:pass@ep-xxx.neon.tech/neondb?sslmode=require"
  exit 1
fi
grep -q '^DB_SSL=' .env || echo "DB_SSL=true" >> .env
echo "Database: Neon (from DATABASE_URL in .env) ✓"

# 2. Vercel project
echo ""
echo "--- Vercel Project ---"
if vercel whoami &>/dev/null; then
  echo "Vercel: logged in ✓"
else
  echo "ERROR: Not logged into Vercel. Run: vercel login"
  exit 1
fi
# Link or create the project (non-interactive)
vercel link --yes --project "$APP_NAME" 2>/dev/null || true
# Push env vars to Vercel
vercel env add DATABASE_URL production <<< "$(grep '^DATABASE_URL=' .env | cut -d= -f2-)" 2>/dev/null || true
vercel env add DB_SSL production <<< "true" 2>/dev/null || true
echo "Vercel project linked: $APP_NAME ✓"

echo ""
echo "=== Pre-flight Complete (Vercel + Neon) ==="
echo "Deploy: run 'vercel --prod' from the project root (or push to your git remote)"
echo "Database: Neon serverless Postgres"
