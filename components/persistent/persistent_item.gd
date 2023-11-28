@tool
class_name PersistentItem
extends XRToolsPickable


## Persistent Item Instance Node
##
## The [PersistentItem] type is for instances of items managed by the
## persistence system. The [PersistentItem] type extends from
## [XRToolsPickable] because most items will be moved and carried by the user,
## however picking up and moving may be disabled by editing the
## [XRToolsPickable] and [RigidBody3D] settings.
##
## [PersistentItem] objects may be placed in persistent zones extending from
## [PersistentZone] and will have their state information (such as zone and
## position) managed in the [PersistentWorld] store. That data can be saved to
## file and loaded back.
##
## Extending from [PersistentItem] allows objects to extend the information
## persisted to the [PersistentWorld] store by overriding the
## [method _load_world_state] and [method _save_world_state] methods.


# Group for world-data properties
@export_group("World Data")

## This property specifies the unique ID (or base ID) for this item
@export var item_id : String

## This property specifies the [PersistentItemType] of this item
@export var item_type : PersistentItemType

## This property indicates whether this object was dynamically created
@export var item_dynamic := false

# Group for auto-return properties
@export_group("Auto Return")

## Automatically return to the last pocket when dropped
@export var auto_return := false

## Timeout for auto-return
@export var auto_return_timeout := 2.0


# Destroyed flag
var _destroyed := false

# Last pocket this object was in
var _last_pocket : PersistentPocket

# Auto-return timer node
var _auto_return_timer : Timer


# Add support for is_xr_class
func is_xr_class(p_name : String) -> bool:
	return p_name == "PersistentItem" or super(p_name)


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	# Subscribe to picked_up and dropped signals
	picked_up.connect(_on_picked_up)
	dropped.connect(_on_dropped)


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify item ID is set
	if not item_id:
		warnings.append("PersistentItem ID not zet")

	# Verify the item type is set
	if not item_type:
		warnings.append("PersistentItem Type not set")

	# Verify item is in persistent group
	if not is_in_group("persistent"):
		warnings.append("PersistentItem not in 'persistent' group")

	# Return warnings
	return warnings


# Handle notifications
func _notification(what : int) -> void:
	# Ignore notifications on freeing objects
	if is_queued_for_deletion():
		return

	match what:
		Persistent.NOTIFICATION_LOAD_STATE:
			_load_state()

		Persistent.NOTIFICATION_SAVE_STATE:
			_save_state()

		Persistent.NOTIFICATION_DESTROY:
			_destroy()


## This method is called when the [PersistentItem] is dropped and freed
func drop_and_free():
	super()

	# Propagate destruction to this node and all children
	propagate_notification(Persistent.NOTIFICATION_DESTROY)


# This method loads the item state from [PersistentWorld]. If the
# [PersistentWorld] indicates this item is destroyed then it queues itself
# and all children for destruction, otherwise it restores the items state.
func _load_state() -> void:
	# Restore the item state
	var state = PersistentWorld.instance.get_value(item_id)
	if not state is Dictionary:
		return

	# If the item is recorded as having been destroyed then destroy it
	if state.get("destroyed", false):
		propagate_notification(Persistent.NOTIFICATION_DESTROY)
		return

	# Restore the item state
	_load_world_state(state)


# This method saves the state of the item to [PersistentWorld]. If the item
# is destroyed then the destroyed state is saved to the [PersistentWorld].
func _save_state() -> void:
	# Handle saving destroyed state
	if _destroyed:
		# Dynamic items can just have their ID cleared
		if item_dynamic:
			PersistentWorld.instance.clear_value(item_id)
			return

		# Design-time items must be saved with the destroyed state
		PersistentWorld.instance.set_value(item_id, { destroyed = true })
		return

	# Populate the state information
	var state := {}
	_save_world_state(state)
	PersistentWorld.instance.set_value(item_id, state)


# This method destroys the item by marking it as destroyed, saving the
# destroyed state to the [PersistentWorld], and queueing the instance for
# destruction.
func _destroy() -> void:
	# Mark the item as destroyed and save state
	_destroyed = true
	_save_state()

	# Ensure the item is queued for destruction
	queue_free()


## This method restores item state from the [param state] world data. The
## base implementation just restores the location. Classes extending from
## [PersistentItem] can override this method to load additional item state by
## calling super() to load the basic information and then reading additional
## state information from the dictionary.
func _load_world_state(state : Dictionary) -> void:
	# Restore the location
	var location = state.get("location")
	if location is Transform3D:
		global_transform = location


## This method saves item state to the [param state] world data. The base
## implementation just saves the type and location. Classes extending from
## [PersistentItem] can override this method to save additional item state by
## calling super() to save the basic information and then writing additional
## state information to the dictionary.
func _save_world_state(state : Dictionary) -> void:
	# Save the type and location
	state["type"] = item_type.type_id
	state["location"] = global_transform


# Start the auto-return timer
func _start_auto_return_timer() -> void:
	# Construct the auto-return timer on first use
	if not _auto_return_timer:
		_auto_return_timer = Timer.new()
		_auto_return_timer.one_shot = true
		_auto_return_timer.timeout.connect(_on_auto_return)
		add_child(_auto_return_timer)

	# Start the auto-return timer
	_auto_return_timer.start(auto_return_timeout)


# Called when this object is picked up
func _on_picked_up(_pickable) -> void:
	# Save the last pocket
	if get_picked_up_by() is PersistentPocket:
		_last_pocket = get_picked_up_by()

	# Stop any auto-return timer
	if _auto_return_timer:
		_auto_return_timer.stop()


# Called when this object is dropped
func _on_dropped(_pickable) -> void:
	# Start the auto-return timer if possible
	if auto_return and _last_pocket:
		_start_auto_return_timer()


# Called when the auto-return timer expires
func _on_auto_return() -> void:
	# Skip if the last pocket is invalid
	if not is_instance_valid(_last_pocket):
		return

	# Skip if the last pocket is already holding an object
	if is_instance_valid(_last_pocket.picked_up_object):
		return

	# Instruct the pocket to pick us up
	_last_pocket.pick_up_object.call_deferred(self)
