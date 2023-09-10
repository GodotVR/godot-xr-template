class_name ZoneDatabase
extends Resource


## Zone Database Resource
##
## This resource defines all [ZoneInfo] entries for our game.
## This is used by our loading system to load the correct zone.


## This property is the array of supported zones
@export var zones : Array[ZoneInfo] : set = _set_zones


# Items cache
var _cache := {}

# Items cache valid flag
var _cache_valid := false


## This method get an [ZoneInfo] given its [param zone_id]. If no
## corresponding [ZoneInfo] is found then this function returns null.
func get_zone(zone_id : String) -> ZoneInfo:
	# Populate the cache if necessary
	if not _cache_valid:
		_populate_cache()

	return _cache.get(zone_id)


# Handle setting the items
func _set_zones(p_zones : Array[ZoneInfo]) -> void:
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
