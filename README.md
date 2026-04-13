# 📱 SafeNest UI

A professional-grade, cross-platform UI Safe Area simulator and smart layout manager for Godot 4. Manage notches, taskbars, and safe margin bounds seamlessly directly within the editor!

---

## 🛑 What problem it solves

When designing UI for mobile devices or web browsers, developers face "unsafe" screen areas:
- iPhone/Android notches and punch-holes
- Bottom home-swipe indicators (Home Bars)
- Browser UI overlays

Normally, to test if your UI overlaps with a notch, you have to export the game to a physical phone, see it looks broken, adjust margins, and export again. **SafeNest UI eliminates this iteration loop.** It brings the physical device's "unsafe boundaries" right into your Godot Editor, allowing you to adapt your `Control` nodes with one click.

---

## ⚙️ How it works

SafeNest UI is completely **stateless and non-destructive**. 

When you apply a safe layout to a UI element, the addon quietly caches your original, pristine layout inside the node's `meta` data. This means you can swap between a "Mobile Portrait" simulation and a "Tablet Landscape" simulation infinitely without your UI permanently shrinking or tearing (additive distortion). 

At runtime, the `SafeAreaService` automatically asks the OS (`DisplayServer`) for the real physical safe area and applies your exact design logic mathematically.

---

## 👁️ Preview vs Apply

The addon uses a highly protective Dock Panel workflow:

- **Preview (Non-Destructive):** Renders a red transparent overlay over your game canvas showing exactly where the "danger zones" (notches/bars) are for the selected profile. **This does NOT modify your nodes or your project.**
- **Apply Layout (Reversible):** Shrinks, moves, or pads your selected `Control` nodes to safely escape the red zones. Fully supports Godot's Undo (`Ctrl+Z`) and can be reverted anytime via the `Restore Original Layout` button.
- **Apply Resolution (Destructive ⚠):** Actually changes your `ProjectSettings` Window Size to match the simulated device. Use this only when you want to permanently change your base workspace resolution.

---

## 🧩 Smart Placement Modes

Godot UI anchors can be tricky. SafeNest UI comes with an intelligent layout adapter that avoids destructively stretching sub-components. Select a node, pick a placement mode, and press Apply:

1. **Full Screen (Root HUD):** Applies safe area margins uniformly from all 4 sides. Best used on the main transparent `Control` that holds your entire UI.
2. **Top Wide (Upper Bar):** Snaps a top-bar cleanly beneath top notches, stretching horizontally but strictly preserving your original height.
3. **Bottom Wide (Lower Bar):** Snaps a bottom action-bar cleanly above home-indicators, preserving original height.
4. **Keep Anchors (Offsets Only):** Preserves your custom centering and anchoring, softly pushing the offsets inward only if they violate a safe margin.

---

## 🕹️ Demo Scene

Want to see it in action without risking your own project? 
Open `addons/safenest_ui/demo/demo_smart_placement.tscn`.

This file contains a fully configured "Customer Demo" featuring a real-world Game HUD (Top Bar with Health/Scores, Bottom Bar with Joystick/Attack skills). 
1. Open the scene.
2. Select a profile from the **SafeNest UI** dock.
3. Click **Preview Overlay** to see the notch boundaries.
4. Select `TopBar` and apply **Top Wide**.
5. Select `BottomBar` and apply **Bottom Wide**.
Watch how the UI intelligently dodges the hardware constraints!

---

## 📦 Current V1 Scope

The V1 release focuses on robust Editor workflow and mathematical stability:
- 5 Built-in simulation profiles (Mobile Portrait/Landscape, Tablet, Web, Desktop).
- Comprehensive Edge-case handling (rejects invalid nodes, heals corrupted cache, prevents zero-margin runtime divides).
- Undo/Redo integration.
- Intelligent `LayoutAdapter` and runtime `SafeAreaService`.
- 100% GDScript, zero external dependencies.

*Future updates will focus on user-defined custom device profiles and visual runtime-reactive nodes.*

---

### License
[MIT License](LICENSE)
