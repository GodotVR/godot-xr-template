@tool
class_name PersistentZone
extends XRToolsSceneBase


## Persistent Zone Node
##
## The [PersistentNode] class is an extension of [XRToolsSceneBase] which
## manages the state of the zones [ItemInstance] objects through the
## [WorldData] persistence system.


# Group for world-data properties
@export_group("World Data")

## This property specifies the unique ID of this zone
@export var zone_id : String

## This property specifies the [ItemDatabase] for spawning items
@export var item_database : ItemDatabase


# Add support for is_xr_class
func is_xr_class(name : String) -> bool:
	return name == "PersistentZone" or super(name)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# call the base
	super()


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify zone ID is set
	if not zone_id:
		warnings.append("Zone ID not zet")

	# Verify the item database is set
	if not item_database:
		warnings.append("Item Database not set")

	# Return warnings
	return warnings


## Handle zone loaded
func scene_loaded(user_data = null):
	super(user_data)

	# Notify all "world_state" objects in the zone to load their state, and
	# save the IDs for any that are ItemInstance in this zone.
	var items_in_zone := {}
	var pockets_in_zone := {}
	for node in get_tree().get_nodes_in_group("world_state"):
		node.load_world_state()
		if node is ItemInstance and not node.is_queued_for_deletion():
			items_in_zone[node.item_id] = node
		elif node is PersistentPocket:
			pockets_in_zone[node.pocket_id] = node

	# Handle the situation where the world-data overrides the items expected to
	# be in this zone
	var zone_items = WorldData.instance.get_value(zone_id)
	if zone_items is Array:
		# Create any items missing from the zone
		for item_id in zone_items:
			if not items_in_zone.has(item_id):
				_create_item_instance(item_id)

		# Destroy any items not intended to be in this zone
		for item_id in items_in_zone:
			if not zone_items.has(item_id):
				items_in_zone[item_id].queue_free()

	# Handle items held by the players left hand
	var left_pickup := XRToolsFunctionPickup.find_left($XROrigin3D)
	var left_item_id = WorldData.instance.get_value("player.left_hand")
	if left_pickup and left_item_id is String:
		var left_instance := _create_item_instance(left_item_id)
		if left_instance:
			left_instance.global_transform = left_pickup.global_transform
			left_pickup._pick_up_object(left_instance)

	# Handle items held by the players right hand
	var right_pickup := XRToolsFunctionPickup.find_right($XROrigin3D)
	var right_item_id = WorldData.instance.get_value("player.right_hand")
	if right_pickup and right_item_id is String:
		var right_instance := _create_item_instance(right_item_id)
		if right_instance:
			right_instance.global_transform = right_pickup.global_transform
			right_pickup._pick_up_object(right_instance)

	# Handle items held in pockets
	for pocket_id in pockets_in_zone:
		var pocket_item_id = WorldData.instance.get_value(pocket_id)
		if pocket_item_id is String:
			var pocket_item := _create_item_instance(pocket_item_id)
			if pocket_item:
				var pocket : PersistentPocket = pockets_in_zone[pocket_id]
				pocket_item.global_transform = pocket.global_transform
				pocket.pick_up_object(pocket_item)


## Handle zone exiting
func scene_exiting(user_data = null):
	super(user_data)

	# Notify all "world_state" objects in the zone to save their state, and
	# save the IDs for any that are ItemInstance in this zone.
	var items_in_zone : Array[String] = []
	var pockets_in_zone := {}
	for node in get_tree().get_nodes_in_group("world_state"):
		node.save_world_state()
		if node is ItemInstance:
			items_in_zone.append(node.item_id)
		elif node is PersistentPocket:
			pockets_in_zone[node.pocket_id] = node

	# Handle items held in the players left hand
	var left_pickup := XRToolsFunctionPickup.find_left($XROrigin3D)
	if left_pickup and \
			left_pickup.picked_up_object and \
			left_pickup.picked_up_object is ItemInstance:
		# The player.left_hand holds the item instead of the zone
		var left_item_id : String = left_pickup.picked_up_object.item_id
		WorldData.instance.set_value("player.left_hand", left_item_id)
		items_in_zone.erase(left_item_id)
	else:
		# The player.left_hand is empty
		WorldData.instance.clear_value("player.left_hand")

	# Handle items held in the players right hand
	var right_pickup := XRToolsFunctionPickup.find_right($XROrigin3D)
	if right_pickup and \
			right_pickup.picked_up_object and \
			right_pickup.picked_up_object is ItemInstance:
		# The player.right_hand holds the item instead of the zone
		var right_item_id : String = right_pickup.picked_up_object.item_id
		WorldData.instance.set_value("player.right_hand", right_item_id)
		items_in_zone.erase(right_item_id)
	else:
		# The player.right_hand is empty
		WorldData.instance.clear_value("player.right_hand")

	# Handle items held in the players pockets
	for pocket_id in pockets_in_zone:
		var pocket : PersistentPocket = pockets_in_zone[pocket_id]
		if pocket.picked_up_object and \
				pocket.picked_up_object is ItemInstance:
			# The pocket holds the item instead of the zone
			var pocket_item_id : String = pocket.picked_up_object.item_id
			WorldData.instance.set_value(pocket_id, pocket_item_id)
			items_in_zone.erase(pocket_item_id)
		else:
			# The pocket is empty
			WorldData.instance.clear_value(pocket_id)

	# Save the items held by the zone
	WorldData.instance.set_value(zone_id, items_in_zone)


# Create an ItemInstance from its [param item_id]. This is used when loading a
# scene that contains an item carried by the user from a different scene.
func _create_item_instance(item_id : String) -> ItemInstance:
	# Get the items state information
	var state = WorldData.instance.get_value(item_id)
	if not state is Dictionary:
		push_warning("Item %s not in world-data" % item_id)
		return null

	# Get the items type_id
	var item_type_id = state.get("type")
	if not item_type_id is String:
		push_warning("Item %s does not define type" % item_id)
		return null

	# Get the ItemType
	var item_type := item_database.get_type(item_type_id)
	if not item_type:
		push_warning("Item type %s not in database" % item_type_id)
		return null

	# Load the item scene
	var item_scene : PackedScene = load(item_type.instance_scene)
	if not item_scene:
		push_warning("Item scene %s not valid" % item_type.instance_scene)
		return null

	# Construct the item
	var item : ItemInstance = item_scene.instantiate()
	if not item:
		push_warning("Item scene %s not valid" % item_type.instance_scene)
		return null

	# Initialize the item
	item.item_id = item_id
	item.item_type = item_type
	add_child(item)
	item.load_world_state()
	return item
