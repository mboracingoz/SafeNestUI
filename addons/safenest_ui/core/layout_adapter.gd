## LayoutAdapter
##
## Applies safe area margins to a Control node.
## Adjusts anchors to full rect and sets margins
## so the node stays within the safe area.
class_name LayoutAdapter


## Applies mobile safe layout to the given Control node.
## For optimal Godot UI architecture, this should only be applied to a Root HUD Control or CanvasLayer child.
static func apply_safe_layout(node: Control) -> bool:
	if node == null:
		push_warning("SafeNest UI: No node provided.")
		return false

	# Kural: Eğer nesne bir Container'ın çocuğuysa, ona margin (offset) uygulanamaz çünkü Container buna izin vermez.
	if node.get_parent() is Container:
		push_warning("SafeNest UI: Cannot apply safe layout directly to a Container's child ('%s'). Please apply it to the main HUD Control." % node.name)
		return false

	var margins := SafeAreaService.get_safe_margins()
	
	# Hedefi ekranı kaplayacak şekilde (Full Rect) ayarlar.
	node.anchor_left = 0.0
	node.anchor_top = 0.0
	node.anchor_right = 1.0
	node.anchor_bottom = 1.0

	# Güvenli alan boşluklarını (Margins) offet olarak hedefe uygular.
	node.offset_left = margins["left"]
	node.offset_top = margins["top"]
	node.offset_right = -margins["right"]
	node.offset_bottom = -margins["bottom"]

	return true
