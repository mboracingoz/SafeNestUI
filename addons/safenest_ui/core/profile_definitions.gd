## ProfileDefinitions
##
## Defines standard simulation profiles for SafeNest UI.
## Contains hardcoded resolutions and mock safety metadata (comfort bounds)
## to strictly separate data definition from logic and mutators.
class_name ProfileDefinitions
extends RefCounted

enum Profile {
	MOBILE_PORTRAIT,
	MOBILE_LANDSCAPE,
	TABLET_PORTRAIT,
	DESKTOP_16_9,
	WEB_16_9
}

const PROFILES: Dictionary = {
	Profile.MOBILE_PORTRAIT: {
		"name": "Mobile Portrait",
		"resolution": Vector2(1080, 1920),
		"margins": {"top": 44.0, "bottom": 34.0, "left": 0.0, "right": 0.0}
	},
	Profile.MOBILE_LANDSCAPE: {
		"name": "Mobile Landscape",
		"resolution": Vector2(1920, 1080),
		"margins": {"top": 0.0, "bottom": 24.0, "left": 44.0, "right": 44.0}
	},
	Profile.TABLET_PORTRAIT: {
		"name": "Tablet Portrait",
		"resolution": Vector2(1600, 2560),
		"margins": {"top": 24.0, "bottom": 20.0, "left": 0.0, "right": 0.0}
	},
	Profile.DESKTOP_16_9: {
		"name": "Desktop 16:9",
		"resolution": Vector2(1920, 1080),
		"margins": {"top": 0.0, "bottom": 40.0, "left": 0.0, "right": 0.0}
	},
	Profile.WEB_16_9: {
		"name": "Web 16:9",
		"resolution": Vector2(1280, 720),
		"margins": {"top": 56.0, "bottom": 0.0, "left": 0.0, "right": 0.0}
	}
}

## Given a Profile enum, returns the profile dictionary containing "name", "resolution", "margins".
static func get_profile_data(profile: Profile) -> Dictionary:
	if PROFILES.has(profile):
		return PROFILES[profile]
	return PROFILES[Profile.MOBILE_PORTRAIT] # Default
