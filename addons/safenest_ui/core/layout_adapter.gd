## LayoutAdapter
##
## Applies safe area margins to a Control node.
## Adjusts anchors to full rect and sets margins
## so the node stays within the safe area.
class_name LayoutAdapter


## Applies mobile safe layout to the given Control node.
## Sets anchors to full rect and applies safe area margins.
## Returns true if applied successfully, false otherwise.
static func apply_safe_layout(node: Control) -> bool:
	if node == null:
		push_warning("SafeNest UI: No node provided.")
		return false

	var margins := SafeAreaService.get_safe_margins()
	var screen_size := Vector2(DisplayServer.screen_get_size())

	# Guard against zero screen size.
	if screen_size.x <= 0.0 or screen_size.y <= 0.0:
		push_warning("SafeNest UI: Screen size is zero, cannot apply layout.")
		return false

	# Set anchors to full rect (0 to 1).
	node.anchor_left = 0.0
	node.anchor_top = 0.0
	node.anchor_right = 1.0
	node.anchor_bottom = 1.0

	# Apply safe margins (push edges inward).
	node.offset_left = margins["left"]
	node.offset_top = margins["top"]
	node.offset_right = -margins["right"]
	node.offset_bottom = -margins["bottom"]

	return true
