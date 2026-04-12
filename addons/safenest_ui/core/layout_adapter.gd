## LayoutAdapter
##
## Applies safe area margins to a Control node.
## Adjusts anchors to full rect and sets margins
## so the node stays within the safe area.
class_name LayoutAdapter


## Applies mobile safe layout to the given Control node.
## If the node is inside a Container, it finds the top-most affected parent to avoid distorting children.
static func apply_safe_layout(node: Control) -> bool:
	if node == null:
		push_warning("SafeNest UI: No node provided.")
		return false

	var target_node: Control = node
	
	# Logic: If this node is a child of a Container, we should apply safe area
	# to the container itself (if it's the UI root) or find the first non-container parent.
	# For most HUDs, we want to scale the 'Container' that holds elements, not the elements inside.
	if node.get_parent() is Container:
		var p = node.get_parent()
		while p != null and p is Control:
			target_node = p
			if not p.get_parent() is Container:
				break
			p = p.get_parent()
		push_warning("SafeNest UI: Node is in a container. Applying to parent: " + target_node.name)

	var margins := SafeAreaService.get_safe_margins()
	
	# Set anchors to full rect (0 to 1).
	target_node.anchor_left = 0.0
	target_node.anchor_top = 0.0
	target_node.anchor_right = 1.0
	target_node.anchor_bottom = 1.0

	# Apply safe margins (push edges inward).
	target_node.offset_left = margins["left"]
	target_node.offset_top = margins["top"]
	target_node.offset_right = -margins["right"]
	target_node.offset_bottom = -margins["bottom"]

	return true
