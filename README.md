# 📱 SafeNest UI

A lightweight and production-ready mobile UI toolkit for Godot 4 that fixes safe area, notch, and screen ratio issues with a single click.

---

## 🧠 Overview

SafeNest UI is a Godot 4 addon designed to solve one of the most common problems in mobile game development:

> UI elements breaking across different devices.

Instead of manually adjusting anchors and margins for every resolution, SafeNest UI lets you fix your layout instantly.

---

## 🎯 Problem

Mobile UI development is painful because of:

- Notches and punch-hole cameras
- Different aspect ratios (16:9, 20:9, etc.)
- UI elements going off-screen
- Time wasted on manual adjustments

---

## 💡 Solution

SafeNest UI provides:

- Automatic safe area detection
- One-click layout fixing
- Clean and lightweight implementation
- Debug visualization

---

## 🚀 Features

### ✅ One-Click Mobile Layout Fix
Select any `Control` node and apply a mobile-safe layout instantly.

### 📐 Safe Area Support
Automatically adapts your UI to device safe areas.

### 🧪 Debug Overlay
Visualize safe area boundaries directly on screen.

### 🧩 Editor Integration
Simple and fast workflow inside the Godot editor.

---

## 🎮 How to Use

1. Enable the plugin:
   - Go to **Project Settings → Plugins**
   - Enable **SafeNest UI**

2. Select your UI node:
   - Choose any `Control` node in your scene

3. Apply layout:
   - Click **"Apply Mobile Safe Layout"**

4. (Optional) Enable debug overlay:
   - Add a `Control` node to your scene
   - Attach `addons/safenest_ui/runtime/safe_area_overlay.gd` as its script
   - Unsafe zones will be highlighted in red

---

## 📦 Installation

1. Download or clone this repository
2. Copy the `addons/safenest_ui` folder into your project
3. Enable the plugin in Project Settings

---

## 🧱 Project Structure
addons/safenest_ui/
├── plugin.cfg
├── plugin.gd
├── core/
│ ├── safe_area_service.gd
│ ├── layout_adapter.gd
├── editor/
│ ├── dock_panel.tscn
│ ├── dock_panel.gd
├── runtime/
│ ├── safe_area_overlay.gd
├── demo/
│ ├── demo_scene.tscn

---

## 🧭 Roadmap

### V1
- Safe area detection
- One-click layout fix
- Debug overlay

### V2
- Orientation support
- Layout presets

### V3
- Advanced responsive UI toolkit

---

## 💰 Monetization

This project is part of a larger product strategy:

- Free version (limited features)
- Paid version (itch.io)

---

## 🎯 Target Audience

- Indie developers
- Mobile game developers
- Godot users struggling with UI scaling
- Rapid prototyping workflows

---

## ⚠️ Notes

- Designed to be lightweight and fast
- Built with clean architecture in mind
- Focused on solving real problems, not adding unnecessary complexity

---

## ❤️ Contributing

Currently focused on core development. Contributions may be considered in the future.

---

## 📄 License

[MIT License](LICENSE)
