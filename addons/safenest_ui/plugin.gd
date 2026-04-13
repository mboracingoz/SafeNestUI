@tool
extends EditorPlugin

const DOCK_SCENE := preload("res://addons/safenest_ui/editor/dock_panel.tscn")
const INSPECTOR_PLUGIN_SCRIPT := preload("res://addons/safenest_ui/editor/inspector_plugin.gd")

var _dock_panel: ScrollContainer
var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	_dock_panel = DOCK_SCENE.instantiate()
	_dock_panel.setup(self, get_undo_redo())
	add_control_to_dock(DOCK_SLOT_LEFT_BR, _dock_panel)
	
	_inspector_plugin = INSPECTOR_PLUGIN_SCRIPT.new()
	_inspector_plugin.setup(get_undo_redo())
	add_inspector_plugin(_inspector_plugin)

	# Listen for selection changes to update the panel label.
	var selection := get_editor_interface().get_selection()
	selection.selection_changed.connect(_on_selection_changed)

	print("SafeNest UI: Plugin loaded.")


func _exit_tree() -> void:
	if _inspector_plugin != null:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
		
	if _dock_panel != null:
		remove_control_from_docks(_dock_panel)
		_dock_panel.queue_free()
		_dock_panel = null

	print("SafeNest UI: Plugin unloaded.")


func _on_selection_changed() -> void:
	if _dock_panel == null:
		return

	var selected := get_editor_interface().get_selection().get_selected_nodes()

	if selected.is_empty():
		_dock_panel.update_selected_node_label("Selected: (none)")
		return

	if selected.size() > 1:
		_dock_panel.update_selected_node_label("Selected: %d nodes" % selected.size())
		return

	var node := selected[0]
	var type_hint := " (Control ✓)" if node is Control else " (not a Control)"
	_dock_panel.update_selected_node_label("Selected: " + node.name + type_hint)
