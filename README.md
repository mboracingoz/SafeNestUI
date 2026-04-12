# 📱 SafeNest UI

A professional-grade, cross-platform UI Safe Area simulator and smart layout manager for Godot 4. Manage notches, taskbars, and safe margin bounds seamlessly directly within the editor!

---

## ⚡ Overview

Mobile and cross-platform UI development doesn't have to be a guessing game. **SafeNest UI** allows developers to simulate how their UI will look on various devices (Phones, Tablets, Web Browsers) *without leaving the Godot editor* or needing to export the project. 

It provides a unified **Dock Panel** to preview safe areas non-destructively and instantly adapt your UI components using **Smart Placement** algorithms.

---

## 🔥 Key Features

### 🎮 Multi-Device Simulation Profile
Instantly preview how your application looks across different form factors. Built-in constraints include:
- `Mobile Portrait` & `Mobile Landscape`
- `Tablet Portrait`
- `Desktop 16:9` (Windowed simulation)
- `Web Browser 16:9`

### 🛡️ Non-Destructive Preview
Easily preview safe boundaries and comfort margins with a visual red overlay directly on your 2D canvas without permanently modifying your `ProjectSettings`. Want to officially scale the Editor window to match? Just hit the "Apply Resolution" button.

### 🧠 Smart Placement Auto-Layout
Godot UI anchors can be tricky. SafeNest UI comes with an intelligent layout adapter that avoids destructively stretching sub-components:
- **Full Screen:** Adapts root canvas elements to the exact safe zone padding.
- **Top Wide:** Snaps top-bars cleanly beneath notches without altering original heights.
- **Bottom Wide:** Snaps bottom action-bars cleanly above home-indicators.
- **Keep Anchors:** Preserves your custom ratios, applying protective margin padding dynamically.

### 💾 Stateless Layout Memory
Mistakes happen, device targets change. SafeNest UI inherently caches your original node layouts via Godot's internal metadata system. You can switch between 5 different device profiles and the addon will perfectly reset your UI to its original pristine state before computing the new margins. No infinite squashing, no UI corruption!

---

## 🕹️ Quick Start Guide

1. **Install:** Copy `addons/safenest_ui` to your project and activate from **Project Settings → Plugins**.
2. **Access the Hub:** A new `SafeNest UI` tab will appear in your godot Dock.
3. **Simulate:** Select an emulation profile (e.g., *Mobile Portrait*) and click **Preview Profile**. 
4. **Target:** Select your root UI node or your specific HUD bar in the scene tree.
5. **Apply Smart Placement:** From the Dock Dropdown, specify how your UI should behave (e.g. `Top Wide`) and hit **Apply Safe Layout**.

*💡 Try out the provided demonstration environment in `addons/safenest_ui/demo/demo_smart_placement.tscn` to master the mechanics!*

---

## 🏗️ Technical Architecture
The addon was engineered with enterprise-level precision using the Single Responsibility Principle (SRP):
*   `ProfileDefinitions`: Pure static data layer for form factors.
*   `SafeAreaService`: Core service handling margin conversions and logic dispatching.
*   `ProjectProfileApplier`: Strict mutator that explicitly isolates `ProjectSettings` overriding actions.
*   `LayoutAdapter`: The stateless layout engine fully supporting Godot's `EditorUndoRedoManager` ecosystem.

---

## 🛣️ Roadmap
- Custom User Profiles (Defining custom resolutions and notch values)
- Visual Live Editors
- Runtime Reactive Safe Area Nodes

---

## 📄 License
[MIT License](LICENSE)
