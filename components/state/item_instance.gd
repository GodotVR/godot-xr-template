@tool
class_name ItemInstance
extends XRToolsPickable


## Item Instance Node
##
## The [ItemInstance] type is for instances of items managed by the [WorldData]
## persistence system. The [ItemInstance] type extends from [XRToolsPickable]
## because most items will be moved and carried by the user, however picking up
## and moving may be disabled by editing the [XRToolsPickable] and [RigidBody3D]
## settings.
##
## [ItemInstance] objects may be placed in zones extending from [PersistentZone]
## and will have their state information (such as zone and position) managed in
## the [WorldData] store. That data can be saved to file and loaded back.
##
## Extending from [ItemInstance] allows objects to extend the information
## persisted to the [WorldData] store by overriding the
## [method _load_world_state] and [method _save_world_state] methods.


# Group for world-data properties
@export_group("World Data")

## This property specifies the unique ID (or base ID) for this item
@export var item_id : String

## This property specifies the [ItemType] of this item
@export var item_type : ItemType

## This property indicates whether this object was dynamically created
@export var item_dynamic := false


# Destroyed flag
var _destroyed := false


# Add support for is_xr_class
func is_xr_class(name : String) -> bool:
	return name == "ItemInstance" or super(name)


# Called when the node enters the scene tree for the first time.
func _ready():
	super()


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify item ID is set
	if not item_id:
		warnings.append("Item ID not zet")

	# Verify the item type is set
	if not item_type:
		warnings.append("Item Type not set")

	# Verify item is in world_state group
	if not is_in_group("world_state"):
		warnings.append("Item not in 'world_state' group")

	# Return warnings
	return warnings


func drop_and_free():
	super()

	# Indicate destroyed and save state
	_destroyed = true
	save_world_state()


## This method loads the item instance state from the world data. See
## [method _load_world_state] for extending state storage.
func load_world_state() -> void:
	# Read the item state dictionary
	var state = WorldData.instance.get_value(item_id)
	if not state is Dictionary:
		return

	# Handle destroyed before parsing detailed state
	if state.get("destroyed", false):
		_destroyed = true
		queue_free()
		return

	# Load the world state
	_load_world_state(state)


## This method save the item instance state to the world data. See
## [method _save_world_state] for extending state storage.
func save_world_state() -> void:
	# Handle saving destroyed state
	if _destroyed:
		# Dynamic items can just have their ID cleared
		if item_dynamic:
			WorldData.instance.clear_value(item_id)
			return

		# Design-time items must be saved with the destroyed state
		WorldData.instance.set_value(item_id, { destroyed = true })
		return

	# Populate the state information
	var state := {}
	_save_world_state(state)
	WorldData.instance.set_value(item_id, state)


## This method restores item state from the [param state] world data. The
## base implementation just restores the location. Classes extending from
## ItemInstance can override this method to load additional item state by
## calling super() to load the basic information and then reading additional
## state information from the dictionary.
func _load_world_state(state : Dictionary) -> void:
	# Restore the location
	var location = state.get("location")
	if location is Transform3D:
		global_transform = location


## This method saves item state to the [param state] world data. The base
## implementation just saves the type and location. Classes extending from
## ItemInstance can override this method to save additional item state by
## calling super() to save the basic information and then writing additional
## state information to the dictionary.
func _save_world_state(state : Dictionary) -> void:
	# Save the type and location
	state["type"] = item_type.type_id
	state["location"] = global_transform
