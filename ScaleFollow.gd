extends Node3D

@export var BoundPoint : Vector3
@export var Offset : Vector3

var Copy : Node3D

func _enter_tree():
	Copy = get_parent_node_3d()
	if !Copy:
		push_warning("Parent does not inherit from Node3D, This node will be disabled")
		process_mode = PROCESS_MODE_DISABLED
	elif !Copy.has_method("get_aabb"):
		push_warning("Parent does not have the function 'get_aabb', This node will be diabled")
		process_mode = PROCESS_MODE_DISABLED

func _process(delta):
	var CopyAABB : AABB = Copy.get_aabb()
	position = CopyAABB.position + CopyAABB.size * BoundPoint + Offset
	scale = Copy.scale / 1.0
