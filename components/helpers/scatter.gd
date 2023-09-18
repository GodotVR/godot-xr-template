@tool
class_name Scatter
extends Node3D


## Scatter Meshes Script
##
## This code allows you to quickly place a number of instances of a mesh at
## random locations.


@export var extend : Vector3 = Vector3(1.0, 0.0, 1.0): set = set_extend
@export var instance_count : int = 10: set = set_instance_count
@export var min_scale : float = 1.0: set = set_min_scale
@export var max_scale : float = 1.0: set = set_max_scale
@export var mesh : Mesh: set = set_mesh
@export var material_override : Material: set = set_material_override

var dirty : bool = true
var multi_mesh : MultiMesh
var multi_mesh_instance : MultiMeshInstance3D

func set_extend(new_value):
	extend = new_value
	_set_dirty()

func set_instance_count(new_value):
	instance_count = new_value
	_set_dirty()

func set_min_scale(new_value):
	min_scale = new_value
	_set_dirty()

func set_max_scale(new_value):
	max_scale = new_value
	_set_dirty()

func set_mesh(new_mesh):
	mesh = new_mesh
	if multi_mesh:
		multi_mesh.mesh = mesh

func set_material_override(new_material):
	material_override = new_material
	if multi_mesh_instance:
		multi_mesh_instance.material_override = material_override

func _set_dirty():
	if !dirty:
		dirty = true
		call_deferred("_update_multimesh")

func _update_multimesh():
	if !dirty:
		return

	multi_mesh.instance_count = instance_count
	for i in instance_count:
		var t := Transform3D()
		var s := randf_range(min_scale, max_scale)
		t.basis = Basis() \
				.rotated(Vector3.UP, randf_range(-PI, PI)) \
				.scaled(Vector3(s, s, s))
		t.origin = Vector3(
			randf_range(-extend.x, extend.x),
			randf_range(-extend.y, extend.y),
			randf_range(-extend.z, extend.z))
		multi_mesh.set_instance_transform(i, t)

	dirty = false

# Called when the node enters the scene tree for the first time.
func _ready():
	multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.mesh = mesh

	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.multimesh = multi_mesh
	multi_mesh_instance.material_override = material_override
	add_child(multi_mesh_instance)

	# First time creating our multimesh
	_update_multimesh()

