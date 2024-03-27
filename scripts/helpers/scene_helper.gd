class_name SceneHelper

static func replace_scene(parent: Node, scene: PackedScene):
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	parent.add_child(scene.instantiate(), true)
