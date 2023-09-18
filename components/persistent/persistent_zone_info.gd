class_name PersistentZoneInfo
extends Resource


## Persistent Zone Information Resource
##
## This resource defines a zone


## This property specifies the unique zone ID
@export var zone_id : String

## This property specifies the scene-file for instancing a [PersistentZone]
@export_file('*.tscn') var instance_scene : String
