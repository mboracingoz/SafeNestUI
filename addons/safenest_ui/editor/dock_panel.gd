@tool
extends VBoxContainer

## Dock panel script for SafeNest UI.
## Handles node selection display and apply button logic.

var _editor_plugin: EditorPlugin


func setup(plugin: EditorPlugin) -> void:
	_editor_plugin = plugin


func _ready() -> void:
	%ApplyButton.pressed.connect(_on_apply_pressed)


func _on_apply_pressed() -> void:
	if _editor_plugin == null:
		_set_status("Error: Plugin reference missing.", true)
		return

	# Get the currently selected node in the editor.
	var selection := _editor_plugin.get_editor_interface().get_selection()
	var selected_nodes := selection.get_selected_nodes()

	if selected_nodes.is_empty():
		_set_status("No node selected.", true)
		return

	var node := selected_nodes[0]

	if not node is Control:
		_set_status("Selected node is not a Control.", true)
		return

	# Apply safe layout via LayoutAdapter.
	var success := LayoutAdapter.apply_safe_layout(node as Control)

	if success:
		_set_status("Layout applied to: " + node.name, false)
	else:
		_set_status("Failed to apply layout.", true)


func _set_status(message: String, is_error: bool) -> void:
	%StatusLabel.text = message
	if is_error:
		%StatusLabel.add_theme_color_override("font_color", Color.TOMATO)
	else:
		%StatusLabel.add_theme_color_override("font_color", Color.LAWN_GREEN)


func update_selected_node_label(node_name: String) -> void:
	%SelectedNodeLabel.text = "Selected: " + node_name
