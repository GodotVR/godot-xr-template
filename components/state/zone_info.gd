class_name ZoneInfo
extends Resource


## Zone Info Resource
##
## This resource defines a zone


## This property specifies the unique type ID
@export var zone_id : String

## This property specifies the scene-file for instancing the zone
@export_file('*.tscn') var instance_scene : String
