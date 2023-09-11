@tool
class_name PersistentZone
extends XRToolsSceneBase


## Persistent Zone Node
##
## The [PersistentNode] class is an extension of [XRToolsSceneBase] which
## manages the state of the zones [PersistentItem] objects through the
## persistence system.


# Group for world-data properties
@export_group("World Data")

## This property specifies the persistent zone information
@export var zone_info : PersistentZoneInfo


# Add support for is_xr_class
func is_xr_class(p_name : String) -> bool:
	return p_name == "PersistentZone" or super(p_name)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# call the base
	super()


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify zone info is set
	if not zone_info:
		warnings.append("Zone ID not zet")

	# Return warnings
	return warnings


## Handle zone loaded
func scene_loaded(user_data = null):
	super(user_data)

	# Save the current zone
	GameState.current_zone = self

	# Find all PersistentItem instances designed into the zone
	var items_in_zone := {}
	for node in XRTools.find_xr_children(self, "*", "PersistentItem"):
		items_in_zone[node.item_id] = node

	# Find the zone items the PersistentWorld thinks should be in this zone.
	var zone_items = PersistentWorld.instance.get_value(zone_info.zone_id)
	
	# Free items designed into the zone but PersistentWorld thinks should
	# be removed.
	if zone_items is Array:
		for item_id in items_in_zone:
			if not zone_items.has(item_id):
				var item : PersistentItem = items_in_zone[item_id]
				item.get_parent().remove_child(item)
				item.queue_free()

	# Load world-state for all items in the zone
	propagate_notification(Persistent.NOTIFICATION_LOAD_STATE)

	# Create items missing from the zone but PersistentWorld thinks should be
	# present.
	if zone_items is Array:
		for item_id in zone_items:
			if not items_in_zone.has(item_id):
				create_item_instance(item_id)

	# Create items held by the players left hand
	var left_pickup := XRToolsFunctionPickup.find_left($XROrigin3D)
	var left_item_id = PersistentWorld.instance.get_value("player.left_hand")
	if left_pickup and left_item_id is String:
		var left_instance := create_item_instance(left_item_id)
		if left_instance:
			left_instance.global_transform = left_pickup.global_transform
			left_pickup._pick_up_object.call_deferred(left_instance)

	# Create items held by the players right hand
	var right_pickup := XRToolsFunctionPickup.find_right($XROrigin3D)
	var right_item_id = PersistentWorld.instance.get_value("player.right_hand")
	if right_pickup and right_item_id is String:
		var right_instance := create_item_instance(right_item_id)
		if right_instance:
			right_instance.global_transform = right_pickup.global_transform
			right_pickup._pick_up_object.call_deferred(right_instance)


## Handle zone exiting
func scene_exiting(user_data = null):
	super(user_data)

	# Ensure the zone state is saved before exiting the zone
	save_world_state()

	# Clear the current zone
	GameState.current_zone = self
	


## This method saves the state of the zone to the [PersistentWorld]. This gets
## called upon exiting the zone; but it should also be called before saving
## the game.
func save_world_state() -> void:
	# Save world-state for all items in the zone
	propagate_notification(Persistent.NOTIFICATION_SAVE_STATE)
	
	# Identify items held directly by the zone
	var items_in_zone : Array[String] = []
	for node in get_tree().get_nodes_in_group("persistent"):
		if is_item_held_by_zone(node):
			items_in_zone.append(node.item_id)

	# Save the items held by the zone
	PersistentWorld.instance.set_value(zone_info.zone_id, items_in_zone)

	# Handle items held in the players left hand
	var left_pickup := XRToolsFunctionPickup.find_left($XROrigin3D)
	if left_pickup and \
		is_instance_valid(left_pickup.picked_up_object) and \
		left_pickup.picked_up_object is PersistentItem:
		# The player.left_hand holds the item
		PersistentWorld.instance.set_value(
			"player.left_hand",
			left_pickup.picked_up_object.item_id)
	else:
		# The player.left_hand is empty
		PersistentWorld.instance.clear_value("player.left_hand")

	# Handle items held in the players right hand
	var right_pickup := XRToolsFunctionPickup.find_right($XROrigin3D)
	if right_pickup and \
		is_instance_valid(right_pickup.picked_up_object) and \
		right_pickup.picked_up_object is PersistentItem:
		# The player.right_hand holds the item
		PersistentWorld.instance.set_value(
			"player.right_hand",
			 right_pickup.picked_up_object.item_id)
	else:
		# The player.right_hand is empty
		PersistentWorld.instance.clear_value("player.right_hand")


## Find the [PersistentZone] containing a given node
static func find_instance(node : Node) -> PersistentZone:
	return XRTools.find_xr_ancestor(
		node,
		"*",
		"PersistentZone") as PersistentZone


# Create a [PersistentItem] from its [param item_id]. This is used when
# loading a scene that contains an item carried by the user from a different
# scene.
func create_item_instance(item_id : String) -> PersistentItem:
	# Get the items state information
	var state = PersistentWorld.instance.get_value(item_id)
	if not state is Dictionary:
		push_warning("Item %s not in world-data" % item_id)
		return null

	# Get the items type_id
	var item_type_id = state.get("type")
	if not item_type_id is String:
		push_warning("Item %s does not define type" % item_id)
		return null

	# Get the PersistentItemType
	var item_type := PersistentWorld.instance.item_database.get_type(item_type_id)
	if not item_type:
		push_warning("Item type %s not in database" % item_type_id)
		return null

	# Load the item scene
	var item_scene : PackedScene = load(item_type.instance_scene)
	if not item_scene:
		push_warning("Item scene %s not valid" % item_type.instance_scene)
		return null

	# Construct the item
	var item : PersistentItem = item_scene.instantiate()
	if not item:
		push_warning("Item scene %s not valid" % item_type.instance_scene)
		return null

	# Initialize the item
	item.item_id = item_id
	item.item_type = item_type
	item.propagate_notification(Persistent.NOTIFICATION_LOAD_STATE)
	add_child(item)
	return item


# This method returns true if the node is an item held by a zone rather than
# being held by some sort of persistent object such as a PersistentPocket or 
# an XRToolsFunctionPickup.
static func is_item_held_by_zone(node : Node) -> bool:
	# Skip if not valid
	if not is_instance_valid(node):
		return false

	# Skip if not an PersistentItem
	if not node is PersistentItem:
		return false

	# If the node isn't held by anything valid then it's held by the zone
	if not is_instance_valid(node.picked_up_by):
		return true

	# If held by a PersistentPocket then it's not held by the zone
	if node.picked_up_by is PersistentPocket:
		return false

	# If held by an XRToolsFunctionPickup the it's not held by the zone
	if node.picked_up_by is XRToolsFunctionPickup:
		return false

	# Node is held by a non-persistent mechanism in the zone
	push_warning("Item ", node.item_id, " held by non-persistent ", node.picked_up_by)
	return true
