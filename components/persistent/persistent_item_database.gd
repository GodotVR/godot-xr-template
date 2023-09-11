class_name PersistentItemDatabase
extends Resource


## Persistent Item Database Resource
##
## This resource defines all [PersistentItemType] items supported by the
## persistence system. The [PersistentZone] classe use this resource when
## creating [PersistentItem] instances.


## This property is the array of supported persistent item types
@export var items : Array[PersistentItemType] : set = _set_items


# Items cache
var _cache := {}

# Items cache valid flag
var _cache_valid := false


## This method gets a [PersistentItemType] given its [param type_id]. If no
## corresponding [PersistentItemType] is found then this function returns null.
func get_type(type_id : String) -> PersistentItemType:
	# Populate the cache if necessary
	if not _cache_valid:
		_populate_cache()

	return _cache.get(type_id)


# Handle setting the items
func _set_items(p_items : Array[PersistentItemType]) -> void:
	# Save the new items
	items = p_items

	# Invalidate the cache
	_cache_valid = false


# Populate the type cache
func _populate_cache() -> void:
	# Populate the cache
	_cache = {}
	for item in items:
		_cache[item.type_id] = item

	# Indicate the cache is valid
	_cache_valid = true
