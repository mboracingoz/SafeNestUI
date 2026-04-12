@tool
extends VBoxContainer

var _editor_plugin: EditorPlugin
var _undo_redo: EditorUndoRedoManager


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
	get_tree().call_group("safe_area_overlay", "queue_redraw")
	_set_status("Overlay updated — no project settings changed.", false)


func _on_apply_res_pressed() -> void:
	ProjectProfileApplier.apply_profile_to_project(SafeAreaService.current_editor_profile)
	_set_status("Project resolution updated. (Destructive — check Project Settings)", false)


func _on_apply_layout_pressed() -> void:
	var valid_controls := _get_selected_controls()
	if valid_controls.is_empty():
		_set_status("No Control node selected.", true)
		return

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
	var valid_controls := _get_selected_controls()
	if valid_controls.is_empty():
		_set_status("No Control node selected.", true)
		return

	var restored := 0
	_undo_redo.create_action("SafeNest: Restore Original Layout")
	for control in valid_controls:
		_undo_redo.add_undo_property(control, "anchor_left",   control.anchor_left)
		_undo_redo.add_undo_property(control, "anchor_top",    control.anchor_top)
		_undo_redo.add_undo_property(control, "anchor_right",  control.anchor_right)
		_undo_redo.add_undo_property(control, "anchor_bottom", control.anchor_bottom)
		_undo_redo.add_undo_property(control, "offset_left",   control.offset_left)
		_undo_redo.add_undo_property(control, "offset_top",    control.offset_top)
		_undo_redo.add_undo_property(control, "offset_right",  control.offset_right)
		_undo_redo.add_undo_property(control, "offset_bottom", control.offset_bottom)
		_undo_redo.add_do_method(LayoutAdapter, "restore_original_layout", control)
		restored += 1
	_undo_redo.commit_action()

	if restored > 0:
		_set_status("Restored %d node(s) to original layout." % restored, false)
	else:
		_set_status("No cached layout found on selected node(s).", true)


func update_selected_node_label(text: String) -> void:
	%SelectedNodeLabel.text = text


# --- Helpers ---

func _get_selected_controls() -> Array[Control]:
	var selection := _editor_plugin.get_editor_interface().get_selection()
	var result: Array[Control] = []
	for node in selection.get_selected_nodes():
		if node is Control:
			result.append(node as Control)
	return result


func _set_status(message: String, is_error: bool) -> void:
	%StatusLabel.text = message
	if is_error:
		%StatusLabel.add_theme_color_override("font_color", Color.ORANGE_RED)
	else:
		%StatusLabel.add_theme_color_override("font_color", Color.LAWN_GREEN)
