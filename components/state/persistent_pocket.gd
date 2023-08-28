@tool
class_name PersistentPocket
extends XRToolsSnapZone


## Persistent Pocket Node
##
## The [PersistentPocket] type holds items managed by the [WorldData]
## persistence system. The [PersistentPocket] type extends from
## [XRToolsSnapZone] to allow [ItemInstance] objects to be snapped or
## removed by the player.


# Group for world-data properties
@export_group("World Data")

## This property specifies the unique ID of this pocket
@export var pocket_id : String


# Add support for is_xr_class
func is_xr_class(name : String) -> bool:
	return name == "PersistentPocket" or super(name)


# Called when the node enters the scene tree for the first time.
func _ready():
	super()


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify pocket ID is set
	if not pocket_id:
		warnings.append("Pocket ID not zet")

	# Verify pocket is in world_state group
	if not is_in_group("world_state"):
		warnings.append("Pocket not in 'world_state' group")

	# Return warnings
	return warnings


func load_world_state() -> void:
	# Unused for now, as the PersistentZone saves all persistent containers
	# such as pockets or hands.
	pass


func save_world_state() -> void:
	# Unused for now, as the PersistentZone saves all persistent containers
	# such as pockets or hands.
	pass
