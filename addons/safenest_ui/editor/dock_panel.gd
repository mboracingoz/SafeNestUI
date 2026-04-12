@tool
extends VBoxContainer

## Dock panel script for SafeNest UI.
## Handles node selection display and apply button logic.

var _editor_plugin: EditorPlugin
var _undo_redo: EditorUndoRedoManager


func setup(plugin: EditorPlugin, undo_redo_manager: EditorUndoRedoManager) -> void:
	_editor_plugin = plugin
	_undo_redo = undo_redo_manager


func _ready() -> void:
	%ApplyButton.pressed.connect(_on_apply_pressed)


func _on_apply_pressed() -> void:
	if _editor_plugin == null or _undo_redo == null:
		_set_status("Error: Plugin or UndoRedo missing.", true)
		return

	var selection := _editor_plugin.get_editor_interface().get_selection()
	var selected_nodes := selection.get_selected_nodes()

	if selected_nodes.is_empty():
		_set_status("No node selected.", true)
		return

	var node := selected_nodes[0]
	if not node is Control:
		_set_status("Selected node is not a Control.", true)
		return

	var control := node as Control

	# Start UndoRedo action.
	_undo_redo.create_action("Apply Mobile Safe Layout")

	# Record UNDO data: Save current state before changing anything.
	_undo_redo.add_undo_property(control, "anchor_left", control.anchor_left)
	_undo_redo.add_undo_property(control, "anchor_top", control.anchor_top)
	_undo_redo.add_undo_property(control, "anchor_right", control.anchor_right)
	_undo_redo.add_undo_property(control, "anchor_bottom", control.anchor_bottom)
	_undo_redo.add_undo_property(control, "offset_left", control.offset_left)
	_undo_redo.add_undo_property(control, "offset_top", control.offset_top)
	_undo_redo.add_undo_property(control, "offset_right", control.offset_right)
	_undo_redo.add_undo_property(control, "offset_bottom", control.offset_bottom)

	# Record DO data: Apply the layout.
	_undo_redo.add_do_method(LayoutAdapter, "apply_safe_layout", control)

	# Commit the action.
	_undo_redo.commit_action()

	_set_status("Layout applied with Undo support: " + control.name, false)


func _set_status(message: String, is_error: bool) -> void:
	%StatusLabel.text = message
	if is_error:
		%StatusLabel.add_theme_color_override("font_color", Color.TOMATO)
	else:
		%StatusLabel.add_theme_color_override("font_color", Color.LAWN_GREEN)


func update_selected_node_label(node_name: String) -> void:
	%SelectedNodeLabel.text = "Selected: " + node_name
