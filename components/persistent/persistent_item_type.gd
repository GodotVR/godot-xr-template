class_name PersistentItemType
extends Resource


## Persistent Item Type Resource
##
## This resource defines a type of persistent items managed by the
## persistence system.


## This property specifies the unique type ID
@export var type_id : String

## This property specifies the scene-file for instancing the [PersistentItem]
@export_file('*.tscn') var instance_scene : String
