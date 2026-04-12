@tool
extends EditorInspectorPlugin

var _undo_redo: EditorUndoRedoManager


func setup(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo


func _can_handle(object: Object) -> bool:
	# Disabled to prevent conflict with Dock Panel placement modes.
	# The Dock Panel is the only safe way to apply layout now.
	return false


func _parse_begin(object: Object) -> void:
	var control := object as Control
	
	# Inspector'un en üstüne eklenecek buton
	var button := Button.new()
	button.text = " Apply Mobile Safe Layout"
	button.icon = preload("res://addons/safenest_ui/icon.svg")
	button.expand_icon = true
	# Butona ikon ekleyip, boyutunu metin hizasına getirebiliriz:
	# Godot 4'te ikon boyutu genelde otomatik ayarlanır tam sığmazsa diye.
	
	# Butona basıldığında çalışacak fonksiyon (UndoRedo destekli)
	button.pressed.connect(_on_apply_pressed.bind(control))
	
	# Butonun etrafına biraz boşluk koyalım (UI estetiği için)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.add_child(button)
	
	# Butonu Inspector paneline ekle
	add_custom_control(margin)


func _on_apply_pressed(control: Control) -> void:
	if _undo_redo == null:
		return
		
	# Geri alma (Undo/Redo) aksiyonunu başlat ve kaydet.
	_undo_redo.create_action("Apply Mobile Safe Layout (Inspector)")
	
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
	_undo_redo.commit_action()
