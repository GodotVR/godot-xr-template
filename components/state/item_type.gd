class_name ItemType
extends Resource


## Item Type Resource
##
## This resource defines a type of item managed by the [WorldData] persistence
## system.


## This property specifies the unique type ID
@export var type_id : String

## This property specifies the scene-file for instancing the type
@export_file('*.tscn') var instance_scene : String
