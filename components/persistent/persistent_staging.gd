@tool
class_name PersistentStaging
extends XRToolsStaging


## Persistent Staging instance
static var instance : PersistentStaging


# Add support for is_xr_class on XRTools classes
func is_xr_class(p_name : String) -> bool:
	return p_name == "PersistentStaging"


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	# Register ourselves as the persistent stage instances
	instance = self
