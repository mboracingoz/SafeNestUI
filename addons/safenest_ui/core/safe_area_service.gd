## SafeAreaService
##
## Reads or simulates the device safe area.
## Returns a Rect2 representing the usable screen region
## that avoids notches, rounded corners, and system bars.
class_name SafeAreaService


## Returns the safe area as a Rect2 in pixels.
## On mobile devices, reads from DisplayServer.
## On desktop/editor, returns the full screen rect as fallback.
static func get_safe_area() -> Rect2:
	var safe_rect := Rect2(DisplayServer.get_display_safe_area())

	# Fallback: if safe area is empty or zero, use full screen size.
	if safe_rect.size.x <= 0.0 or safe_rect.size.y <= 0.0:
		var screen_size := DisplayServer.screen_get_size()
		safe_rect = Rect2(Vector2.ZERO, Vector2(screen_size))

	return safe_rect


## Returns safe area margins (top, bottom, left, right) in pixels.
## Margins represent the unsafe zones from each screen edge.
static func get_safe_margins() -> Dictionary:
	var safe_rect := get_safe_area()
	var screen_size := Vector2(DisplayServer.screen_get_size())

	return {
		"top": safe_rect.position.y,
		"bottom": screen_size.y - safe_rect.end.y,
		"left": safe_rect.position.x,
		"right": screen_size.x - safe_rect.end.x,
	}
