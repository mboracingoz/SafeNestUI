@tool
extends ScrollContainer

var _editor_plugin: EditorPlugin
var _undo_redo: EditorUndoRedoManager

# Guard: prevents any layout action from firing while a preview redraw is in progress.
var _is_previewing: bool = false


func setup(plugin: EditorPlugin, undo_redo: EditorUndoRedoManager) -> void:
	_editor_plugin = plugin
	_undo_redo = undo_redo

	# --- Simulation Profile Dropdown ---
	%ProfileDropdown.clear()
	for profile_id in ProfileDefinitions.Profile.values():
		var data = ProfileDefinitions.get_profile_data(profile_id)
		%ProfileDropdown.add_item(data["name"], profile_id)

	# --- Placement Dropdown ---
	%PlacementDropdown.clear()
	%PlacementDropdown.add_item("Full Screen (Root HUD)", LayoutAdapter.Placement.FULL_SCREEN)
	%PlacementDropdown.add_item("Top Wide (Upper Bar)", LayoutAdapter.Placement.TOP_WIDE)
	%PlacementDropdown.add_item("Bottom Wide (Lower Bar)", LayoutAdapter.Placement.BOTTOM_WIDE)
	%PlacementDropdown.add_item("Keep Anchors (Offsets Only)", LayoutAdapter.Placement.KEEP_ANCHORS)
	%PlacementDropdown.select(0)

	# --- Connect signals ---
	%ProfileDropdown.item_selected.connect(_on_profile_selected)
	%PlacementDropdown.item_selected.connect(_on_placement_selected)
	%PreviewButton.pressed.connect(_on_preview_pressed)
	%ApplyResButton.pressed.connect(_on_apply_res_pressed)
	%ApplyLayoutButton.pressed.connect(_on_apply_layout_pressed)
	%RestoreButton.pressed.connect(_on_restore_pressed)

	# --- Initial state ---
	%ProfileDropdown.select(SafeAreaService.current_editor_profile)
	_update_info_label(SafeAreaService.current_editor_profile)


func _on_profile_selected(index: int) -> void:
	var profile_id := %ProfileDropdown.get_item_id(index) as ProfileDefinitions.Profile
	SafeAreaService.current_editor_profile = profile_id
	_update_info_label(profile_id)


func _on_placement_selected(_index: int) -> void:
	_update_info_label(SafeAreaService.current_editor_profile)


func _update_info_label(profile_id: ProfileDefinitions.Profile) -> void:
	var data = ProfileDefinitions.get_profile_data(profile_id)
	var res: Vector2 = data["resolution"]
	var m: Dictionary = data["margins"]
	var placement_id := %PlacementDropdown.get_selected_id() as LayoutAdapter.Placement

	var placement_name := ""
	match placement_id:
		LayoutAdapter.Placement.FULL_SCREEN: placement_name = "Full Screen"
		LayoutAdapter.Placement.TOP_WIDE:    placement_name = "Top Wide"
		LayoutAdapter.Placement.BOTTOM_WIDE: placement_name = "Bottom Wide"
		LayoutAdapter.Placement.KEEP_ANCHORS: placement_name = "Keep Anchors"

	var info := "Resolution: %dx%d\n" % [int(res.x), int(res.y)]
	info += "Margins: T:%s  B:%s  L:%s  R:%s\n" % [m["top"], m["bottom"], m["left"], m["right"]]
	info += "Placement: %s\n" % placement_name
	info += "Preview → Non-Destructive ✓\nApply Resolution → Destructive ⚠"
	%InfoLabel.text = info


func _on_preview_pressed() -> void:
	# Preview is strictly non-destructive: it only signals overlays to redraw.
	# It must NEVER call apply_safe_layout or modify any node properties.
	if _is_previewing:
		return
	_is_previewing = true
	get_tree().call_group("safe_area_overlay", "queue_redraw")
	_is_previewing = false
	_set_status("Preview refreshed — no nodes or settings modified.", false)


func _on_apply_res_pressed() -> void:
	ProjectProfileApplier.apply_profile_to_project(SafeAreaService.current_editor_profile)
	_set_status("Project resolution updated. (Destructive — check Project Settings)", false)


func _on_apply_layout_pressed() -> void:
	var result := _get_selected_controls()
	if result["non_control_count"] > 0 and result["controls"].is_empty():
		_set_status("%d selected node(s) are not Controls. Select a Control node." % result["non_control_count"], true)
		return
	if result["controls"].is_empty():
		_set_status("No Control node selected.", true)
		return
	if result["non_control_count"] > 0:
		_set_status("%d non-Control node(s) skipped." % result["non_control_count"], true)

	var valid_controls: Array[Control] = result["controls"]
	var placement_val := %PlacementDropdown.get_selected_id() as LayoutAdapter.Placement

	_undo_redo.create_action("SafeNest: Apply Safe Layout")
	for control in valid_controls:
		_undo_redo.add_undo_property(control, "anchor_left",   control.anchor_left)
		_undo_redo.add_undo_property(control, "anchor_top",    control.anchor_top)
		_undo_redo.add_undo_property(control, "anchor_right",  control.anchor_right)
		_undo_redo.add_undo_property(control, "anchor_bottom", control.anchor_bottom)
		_undo_redo.add_undo_property(control, "offset_left",   control.offset_left)
		_undo_redo.add_undo_property(control, "offset_top",    control.offset_top)
		_undo_redo.add_undo_property(control, "offset_right",  control.offset_right)
		_undo_redo.add_undo_property(control, "offset_bottom", control.offset_bottom)
		_undo_redo.add_do_method(LayoutAdapter, "apply_safe_layout", control, placement_val)
	_undo_redo.commit_action()

	_set_status("Layout applied to %d node(s). (Undo available)" % valid_controls.size(), false)


func _on_restore_pressed() -> void:
	var result := _get_selected_controls()
	if result["non_control_count"] > 0 and result["controls"].is_empty():
		_set_status("%d selected node(s) are not Controls." % result["non_control_count"], true)
		return
	if result["controls"].is_empty():
		_set_status("No Control node selected.", true)
		return

	var valid_controls: Array[Control] = result["controls"]

	# Pre-check: only restore nodes that actually have a cached layout.
	var cacheable: Array[Control] = []
	var skipped_no_cache := 0
	for control in valid_controls:
		if control.has_meta("safenest_original_layout"):
			cacheable.append(control)
		else:
			skipped_no_cache += 1

	if cacheable.is_empty():
		_set_status("No cached layout found. Apply a Safe Layout first.", true)
		return

	_undo_redo.create_action("SafeNest: Restore Original Layout")
	for control in cacheable:
		_undo_redo.add_undo_property(control, "anchor_left",   control.anchor_left)
		_undo_redo.add_undo_property(control, "anchor_top",    control.anchor_top)
		_undo_redo.add_undo_property(control, "anchor_right",  control.anchor_right)
		_undo_redo.add_undo_property(control, "anchor_bottom", control.anchor_bottom)
		_undo_redo.add_undo_property(control, "offset_left",   control.offset_left)
		_undo_redo.add_undo_property(control, "offset_top",    control.offset_top)
		_undo_redo.add_undo_property(control, "offset_right",  control.offset_right)
		_undo_redo.add_undo_property(control, "offset_bottom", control.offset_bottom)
		_undo_redo.add_do_method(LayoutAdapter, "restore_original_layout", control)
	_undo_redo.commit_action()

	var msg := "Restored %d node(s)." % cacheable.size()
	if skipped_no_cache > 0:
		msg += " (%d had no cache, skipped.)" % skipped_no_cache
	_set_status(msg, false)


func update_selected_node_label(text: String) -> void:
	%SelectedNodeLabel.text = text


# --- Helpers ---

# Returns a Dictionary: { "controls": Array[Control], "non_control_count": int }
func _get_selected_controls() -> Dictionary:
	var selection := _editor_plugin.get_editor_interface().get_selection()
	var selected_nodes := selection.get_selected_nodes()

	var result: Array[Control] = []
	var non_control_count := 0
	for node in selected_nodes:
		if node is Control:
			result.append(node as Control)
		else:
			non_control_count += 1

	return {"controls": result, "non_control_count": non_control_count}


func _set_status(message: String, is_error: bool) -> void:
	%StatusLabel.text = message
	if is_error:
		%StatusLabel.add_theme_color_override("font_color", Color.ORANGE_RED)
	else:
		%StatusLabel.add_theme_color_override("font_color", Color.LAWN_GREEN)
