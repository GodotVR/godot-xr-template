@tool
class_name StartZone
extends XRToolsSceneBase


## This property specifies the [ZoneDatabase] for loading zones
@export var zone_database : ZoneDatabase


func _on_start_ui_start_game():
	var current_zone_id = GameState.get_current_zone_id()
	if current_zone_id == "":
		# New game, just load our outside zone as our starting point.
		load_scene("res://game/zones/outside/outside_zone.tscn")
	else:
		var zone_scene : ZoneInfo = zone_database.get_zone(current_zone_id)
		if FileAccess.file_exists(zone_scene.instance_scene):
			load_scene(zone_scene.instance_scene, GameState.get_spawn_point_name())
		else:
			load_scene("res://game/zones/outside/outside_zone.tscn")
