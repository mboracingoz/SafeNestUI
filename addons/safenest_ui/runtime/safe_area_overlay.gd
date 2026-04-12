@tool
extends Control

## SafeAreaOverlay
##
## Draws the unsafe zones (outside safe area) as semi-transparent overlays.
## Toggle visibility to enable/disable the debug view.

## Overlay color for unsafe zones.
@export var overlay_color: Color = Color(1.0, 0.0, 0.0, 0.25):
	set(value):
		overlay_color = value
		queue_redraw()


func _ready() -> void:
	# Add to listener group for editor-time preview updates
	add_to_group("safe_area_overlay")
	# Fill the entire screen.
	anchors_preset = PRESET_FULL_RECT
	mouse_filter = MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	# Logic: Use the Control's own size instead of the viewport to ensure 
	# correct scaling within the editor layout.
	var rect_size := size
	var margins := SafeAreaService.get_safe_margins()

	var top: float = margins["top"]
	var bottom: float = margins["bottom"]
	var left: float = margins["left"]
	var right: float = margins["right"]

	# Top unsafe zone.
	if top > 0.0:
		draw_rect(Rect2(0, 0, rect_size.x, top), overlay_color)

	# Bottom unsafe zone.
	if bottom > 0.0:
		draw_rect(Rect2(0, rect_size.y - bottom, rect_size.x, bottom), overlay_color)

	# Left unsafe zone (between top and bottom).
	if left > 0.0:
		draw_rect(Rect2(0, top, left, rect_size.y - top - bottom), overlay_color)

	# Right unsafe zone (between top and bottom).
	if right > 0.0:
		draw_rect(Rect2(rect_size.x - right, top, right, rect_size.y - top - bottom), overlay_color)
