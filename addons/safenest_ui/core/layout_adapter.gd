## LayoutAdapter
##
## Applies safe area margins to a Control node.
## Adjusts anchors to full rect and sets margins
## so the node stays within the safe area.
class_name LayoutAdapter


## Applies mobile safe layout to the given Control node.
## For optimal Godot UI architecture, this should only be applied to a Root HUD Control or CanvasLayer child.

enum Placement {
	FULL_SCREEN,
	TOP_WIDE,
	BOTTOM_WIDE,
	KEEP_ANCHORS
}

static func apply_safe_layout(node: Control, placement: Placement = Placement.FULL_SCREEN) -> bool:
	# Guard: null check
	if node == null:
		push_warning("SafeNest UI: No node provided.")
		return false

	# Guard: must be a Control — caller from dock panel already filters, but belt-and-suspenders.
	if not node is Control:
		push_warning("SafeNest UI: Node '%s' is not a Control. Skipping." % node.name)
		return false

	# Guard: Container children cannot have manual offsets applied.
	if node.get_parent() is Container:
		push_warning("SafeNest UI: Cannot apply safe layout directly to a Container's child ('%s'). Apply it to the parent instead." % node.name)
		return false

	# --- STATELESS LAYOUT: Caching Original State ---
	var meta_key := "safenest_original_layout"
	if not node.has_meta(meta_key):
		var orig_state = {
			"anchor_left": node.anchor_left,
			"anchor_top": node.anchor_top,
			"anchor_right": node.anchor_right,
			"anchor_bottom": node.anchor_bottom,
			"offset_left": node.offset_left,
			"offset_top": node.offset_top,
			"offset_right": node.offset_right,
			"offset_bottom": node.offset_bottom
		}
		node.set_meta(meta_key, orig_state)
	else:
		# Restore original layout to prevent additive distortion
		var orig: Dictionary = node.get_meta(meta_key)
		node.anchor_left = orig["anchor_left"]
		node.anchor_top = orig["anchor_top"]
		node.anchor_right = orig["anchor_right"]
		node.anchor_bottom = orig["anchor_bottom"]
		node.offset_left = orig["offset_left"]
		node.offset_top = orig["offset_top"]
		node.offset_right = orig["offset_right"]
		node.offset_bottom = orig["offset_bottom"]
	# ------------------------------------------------

	var margins := SafeAreaService.get_safe_margins()
	var orig_height := node.size.y # Reference to preserve original height
	
	match placement:
		Placement.FULL_SCREEN:
			# Sets the target to fill the screen (Full Rect).
			node.anchor_left = 0.0
			node.anchor_top = 0.0
			node.anchor_right = 1.0
			node.anchor_bottom = 1.0
			node.offset_left = margins["left"]
			node.offset_top = margins["top"]
			node.offset_right = -margins["right"]
			node.offset_bottom = -margins["bottom"]
			
		Placement.TOP_WIDE:
			# Snaps target to top, sets bottom offset relative to original height.
			node.anchor_left = 0.0
			node.anchor_top = 0.0
			node.anchor_right = 1.0
			node.anchor_bottom = 0.0
			node.offset_left = margins["left"]
			node.offset_top = margins["top"]
			node.offset_right = -margins["right"]
			node.offset_bottom = margins["top"] + orig_height

		Placement.BOTTOM_WIDE:
			# Snaps target to bottom, sets top offset relative to original height.
			node.anchor_left = 0.0
			node.anchor_top = 1.0
			node.anchor_right = 1.0
			node.anchor_bottom = 1.0
			node.offset_left = margins["left"]
			node.offset_top = -margins["bottom"] - orig_height
			node.offset_right = -margins["right"]
			node.offset_bottom = -margins["bottom"]

		Placement.KEEP_ANCHORS:
			# Keeps anchors as is, only shrinks offsets within safe bounds.
			node.offset_left = node.offset_left + margins["left"]
			node.offset_top = node.offset_top + margins["top"]
			node.offset_right = node.offset_right - margins["right"]
			node.offset_bottom = node.offset_bottom - margins["bottom"]

	return true


## Restores the node to its original layout cached before the first safe layout was applied.
## Returns true if a cached state was found and restored, false if none exists.
static func restore_original_layout(node: Control) -> bool:
	# Guard: null check
	if node == null:
		return false

	var meta_key := "safenest_original_layout"
	if not node.has_meta(meta_key):
		push_warning("SafeNest UI: No original layout cached for '%s'. Apply a layout first." % node.name)
		return false

	var orig = node.get_meta(meta_key)

	# Guard: Integrity check — ensure meta is a Dictionary with exactly the expected keys.
	var required_keys := ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom",
						  "offset_left", "offset_top", "offset_right", "offset_bottom"]
	if not orig is Dictionary:
		push_error("SafeNest UI: Cached layout for '%s' is corrupted (not a Dictionary). Removing." % node.name)
		node.remove_meta(meta_key)
		return false
	for key in required_keys:
		if not orig.has(key):
			push_error("SafeNest UI: Cached layout for '%s' is missing key '%s'. Removing." % [node.name, key])
			node.remove_meta(meta_key)
			return false

	# Restore anchors and offsets
	node.anchor_left   = orig["anchor_left"]
	node.anchor_top    = orig["anchor_top"]
	node.anchor_right  = orig["anchor_right"]
	node.anchor_bottom = orig["anchor_bottom"]
	node.offset_left   = orig["offset_left"]
	node.offset_top    = orig["offset_top"]
	node.offset_right  = orig["offset_right"]
	node.offset_bottom = orig["offset_bottom"]

	# Clear the cache so a subsequent apply_safe_layout recaches the restored state.
	node.remove_meta(meta_key)
	return true
