# 🤖 SafeNest UI — AI Agent & Developer Handover Document

**Dear AI Agent / Future Developer:** 
If you are reading this, you are tasked with assisting Bora in maintaining or expanding the SafeNest UI Godot 4.6+ Plugin. Please read these architectural guidelines carefully. **Do not deviate from the core philosophy.**

## 1. Product Philosophy (The "Why")
- **Not a framework:** This is a laser-focused, production-ready tool to solve "Safe Area" (notches, taskbars, punch-holes) UI layout clipping in Godot.
- **Selling Point:** Clean Architecture, single-click usage, and native feeling (Undo/Redo, Inspector integration).
- **Rule of Thumb:** "Fast but not garbage. Small but professional. Minimal but scalable." Do not introduce feature creep or unnecessarily complex patterns.

## 2. Directory Structure & Responsibilities
The project is strictly separated into domain logic components:

`addons/safenest_ui/`
*   `plugin.cfg` / `plugin.gd` : The Godot entry point. Wires the Inspector Plugin and Dock Panel into the editor. It is the ONLY place that should interface with Godot's plugin lifecycle.
*   `core/` : **Pure Domain Logic.** Contains `safe_area_service.gd` (fetching Rect2 safe areas) and `layout_adapter.gd` (pushing anchors/safemargins to a Control node). *Rule: Core MUST NOT import or depend on `editor/` or `runtime/` layers.*
*   `editor/` : **Godot Editor UI.** Contains `dock_panel` (the left-panel UI) and `inspector_plugin` (the button mapped onto the Godot right-panel Inspector). Both utilize Godot 4's `EditorUndoRedoManager` meticulously.
*   `runtime/` : **In-game Logic.** Contains `safe_area_overlay.gd` which uses `_draw()` to paint red rectangles over unsafe zones.
*   `demo/` : Contains the demo scene for itch.io / asset lib testing.

## 3. Strict Development Rules for You (The AI)
1. **Never use `add_do_method(Callable)` with Godot 4 `EditorUndoRedoManager`.** 
   * *Wrong:* `_undo_redo.add_do_method(LayoutAdapter.apply_safe_layout.bind(control))`
   * *Correct:* `_undo_redo.add_do_method(LayoutAdapter, "apply_safe_layout", control)`
2. **Batch Apply Support:** Any editor operations acting on `Control` nodes MUST check `get_editor_interface().get_selection().get_selected_nodes()` in a loop and apply the logic under a *single* `commit_action()` for batch undo/redo support.
3. **No Cross-Contamination:** Never mix tool-script (`@tool`) editor logic inside `runtime` or `core` components unless strictly required for `_draw()` previews.
4. **Step-by-Step Delivery:** When communicating with the user, break down the code. Never give huge chunks. Explain *why* you are making the change, and provide the command for a single-line git commit when the user confirms.

## 4. Where to Go Next (V2 Roadmap)
If the user asks for V2 development, focus on:
- Handling Device Orientation changes (listening to `DisplayServer` signals or Viewport resized signals).
- Advanced Layout Presets.
