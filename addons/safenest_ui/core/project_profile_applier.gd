## ProjectProfileApplier
##
## Mutator class responsible ONLY for modifying Godot Project Settings.
## Strictly separated from data and service layers to maintain Single Responsibility Principle (SRP).
class_name ProjectProfileApplier
extends RefCounted


## Modifies the Godot project's viewport resolution to match the chosen profile.
## WARNING: This is a DESTRUCTIVE action that modifies and saves project settings.
## It should only be called via explicit user interaction (e.g. an "Apply" button).
static func apply_profile_to_project(profile: ProfileDefinitions.Profile) -> void:
	if not Engine.is_editor_hint():
		return

	var data: Dictionary = ProfileDefinitions.get_profile_data(profile)
	var res: Vector2 = data["resolution"]
	
	# Future Feature: We can cache existing ProjectSettings here for a restore_previous_settings() mechanic.

	# Overwrite Window Viewport settings
	ProjectSettings.set_setting("display/window/size/viewport_width", int(res.x))
	ProjectSettings.set_setting("display/window/size/viewport_height", int(res.y))

	# Save to disk to force Godot Editor to recognize the change
	var err := ProjectSettings.save()
	if err != OK:
		push_error("SafeNest UI: Failed to save ProjectSettings!")
		return

	print("SafeNest UI: Applied profile '%s' resolution (%dx%d) to ProjectSettings." % [data["name"], int(res.x), int(res.y)])
