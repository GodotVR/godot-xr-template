class_name PersistentZoneDatabase
extends Resource


## Persistent Zone Database Resource
##
## This resource defines all [PersistentZoneInfo] entries for our game.
## This is used by our loading system to load the correct zone.


## This property is the array of supported zones
@export var zones : Array[PersistentZoneInfo] : set = _set_zones


# Items cache
var _cache := {}

# Items cache valid flag
var _cache_valid := false


## This method get an [PersistentZoneInfo] given its [param zone_id]. If no
## corresponding [PersistentZoneInfo] is found then this function returns null.
func get_zone(zone_id : String) -> PersistentZoneInfo:
	# Populate the cache if necessary
	if not _cache_valid:
		_populate_cache()

	return _cache.get(zone_id)


# Handle setting the items
func _set_zones(p_zones : Array[PersistentZoneInfo]) -> void:
	# Save the new items
	zones = p_zones

	# Invalidate the cache
	_cache_valid = false


# Populate the type cache
func _populate_cache() -> void:
	# Populate the cache
	_cache = {}
	for zone in zones:
		_cache[zone.zone_id] = zone

	# Indicate the cache is valid
	_cache_valid = true
