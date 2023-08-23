@tool
class_name StartZone
extends XRToolsSceneBase


func _on_start_button_pressed():
	load_scene("res://game/zones/outside/outside_zone.tscn")
