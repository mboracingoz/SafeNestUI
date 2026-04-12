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
	if node == null:
		push_warning("SafeNest UI: No node provided.")
		return false

	# Kural: Eğer nesne bir Container'ın çocuğuysa, ona margin (offset) uygulanamaz çünkü Container buna izin vermez.
	if node.get_parent() is Container:
		push_warning("SafeNest UI: Cannot apply safe layout directly to a Container's child ('%s'). Please apply it to the main HUD Control." % node.name)
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
	var orig_height := node.size.y # Orijinal yüksekliği korumak için referans
	
	match placement:
		Placement.FULL_SCREEN:
			# Hedefi ekranı kaplayacak şekilde (Full Rect) ayarlar.
			node.anchor_left = 0.0
			node.anchor_top = 0.0
			node.anchor_right = 1.0
			node.anchor_bottom = 1.0
			node.offset_left = margins["left"]
			node.offset_top = margins["top"]
			node.offset_right = -margins["right"]
			node.offset_bottom = -margins["bottom"]
			
		Placement.TOP_WIDE:
			# Hedefi yukarı asar, alt offset'i orjinal yüksekliğine göre çizer.
			node.anchor_left = 0.0
			node.anchor_top = 0.0
			node.anchor_right = 1.0
			node.anchor_bottom = 0.0
			node.offset_left = margins["left"]
			node.offset_top = margins["top"]
			node.offset_right = -margins["right"]
			node.offset_bottom = margins["top"] + orig_height

		Placement.BOTTOM_WIDE:
			# Hedefi aşağı asar, üst offset'i orjinal yüksekliğine göre negatif çizer.
			node.anchor_left = 0.0
			node.anchor_top = 1.0
			node.anchor_right = 1.0
			node.anchor_bottom = 1.0
			node.offset_left = margins["left"]
			node.offset_top = -margins["bottom"] - orig_height
			node.offset_right = -margins["right"]
			node.offset_bottom = -margins["bottom"]

		Placement.KEEP_ANCHORS:
			# Anchorlara dokunmadan sadece güvenli boşlukları daraltır.
			node.offset_left = node.offset_left + margins["left"]
			node.offset_top = node.offset_top + margins["top"]
			node.offset_right = node.offset_right - margins["right"]
			node.offset_bottom = node.offset_bottom - margins["bottom"]

	return true
