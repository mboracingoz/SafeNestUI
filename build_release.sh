#!/usr/bin/env bash

# SafeNest UI — Release Packager
# This script creates a clean .zip file for Godot Asset Library & Itch.io

cd "$(dirname "$0")"

VERSION="1.0.0"
ZIP_NAME="SafeNestUI_v${VERSION}.zip"
TARGET_DIR="addons/safenest_ui"

echo "📦 Packaging SafeNest UI v${VERSION}..."

# Clean up old zip if exists
rm -f "$ZIP_NAME"

# Create a temporary staging directory
mkdir -p .release_tmp/addons
mkdir -p .release_tmp/Docs

# Copy only the necessary files (ignore raw project files, .git, etc.)
cp -r "$TARGET_DIR" .release_tmp/addons/
cp README.md .release_tmp/ 2>/dev/null
cp -r Docs/* .release_tmp/Docs/ 2>/dev/null

echo "🗜️  Zipping..."
cd .release_tmp
zip -r "../$ZIP_NAME" addons/ README.md Docs/ -q
cd ..

# Cleanup staging area
rm -rf .release_tmp

echo "✅ Success! Built -> $ZIP_NAME"
echo "You can now upload this file to Godot Asset Library or Itch.io."
