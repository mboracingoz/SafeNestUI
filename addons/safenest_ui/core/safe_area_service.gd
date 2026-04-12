## SafeAreaService
##
## Reads or simulates the device safe area.
## Returns a Rect2 representing the usable screen region
## that avoids notches, rounded corners, and system bars.
class_name SafeAreaService


static var current_editor_profile: ProfileDefinitions.Profile = ProfileDefinitions.Profile.MOBILE_PORTRAIT


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
## Falls back to MOBILE_PORTRAIT defaults if the profile or data cannot be resolved.
static func get_safe_margins(override_profile: int = -1) -> Dictionary:
	# Editor mode: always use the simulation profile, never the physical display.
	if Engine.is_editor_hint():
		var p: ProfileDefinitions.Profile = current_editor_profile
		if override_profile != -1:
			# Guard: ensure the override value is a valid Profile enum member.
			if ProfileDefinitions.PROFILES.has(override_profile):
				p = override_profile as ProfileDefinitions.Profile
			else:
				push_warning("SafeNest UI: Invalid profile override '%d'. Falling back to current profile." % override_profile)
		return ProfileDefinitions.get_profile_data(p)["margins"]

	# Runtime logic: read from DisplayServer
	var safe_rect := get_safe_area()
	var screen_size := Vector2(DisplayServer.screen_get_size())

	# Guard: protect against zero/negative screen sizes at runtime.
	if screen_size.x <= 0.0 or screen_size.y <= 0.0:
		push_warning("SafeNest UI: Runtime screen size is zero. Returning zero margins.")
		return {"top": 0.0, "bottom": 0.0, "left": 0.0, "right": 0.0}

	var margins := {
		"top":    safe_rect.position.y,
		"bottom": screen_size.y - safe_rect.end.y,
		"left":   safe_rect.position.x,
		"right":  screen_size.x - safe_rect.end.x,
	}

	# Guard: clamp all margins to non-negative values.
	for key in margins.keys():
		margins[key] = maxf(0.0, margins[key])

	return margins

	
## Returns the ideal screen resolution depending on the selected profile (Editor) or Physical Device (Runtime).
static func get_resolution(override_profile: int = -1) -> Vector2:
	if Engine.is_editor_hint():
		var p: ProfileDefinitions.Profile = current_editor_profile
		if override_profile != -1:
			p = override_profile as ProfileDefinitions.Profile
		return ProfileDefinitions.get_profile_data(p)["resolution"]
		
	return Vector2(DisplayServer.screen_get_size())
