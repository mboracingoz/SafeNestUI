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

	var valid_controls: Array[Control] = []
	for node in selected_nodes:
		if node is Control:
			valid_controls.append(node as Control)

	if valid_controls.is_empty():
		_set_status("No Control nodes selected.", true)
		return

	# Start UndoRedo action. (Bütün değişiklikleri kapsayacak şekilde)
	_undo_redo.create_action("Batch Apply Mobile Safe Layout")

	for control in valid_controls:
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

	_set_status("Layout applied to %d node(s)." % valid_controls.size(), false)

func _set_status(message: String, is_error: bool) -> void:
	%StatusLabel.text = message
	if is_error:
		%StatusLabel.add_theme_color_override("font_color", Color.TOMATO)
	else:
		%StatusLabel.add_theme_color_override("font_color", Color.LAWN_GREEN)


func update_selected_node_label(text: String) -> void:
	%SelectedNodeLabel.text = text
