@tool
class_name GameStaging
extends PersistentStaging


## Game Staging Script
##
## This script registers the staging instance with the [GameState] singleton
## and handles pausing/resuming.


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	# Do not initialise if in the editor
	if Engine.is_editor_hint():
		return

	# Connect events
	scene_loaded.connect(_on_scene_loaded)
	xr_started.connect(_on_xr_started)
	xr_ended.connect(_on_xr_ended)


# This method is called when a scene is loaded
func _on_scene_loaded(_scene : XRToolsSceneBase, _user_data : Variant) -> void:
	# Clear the continue prompt
	prompt_for_continue = false


# This method is called when the player starts the VR experience
func _on_xr_started() -> void:
	# Resume the game
	get_tree().paused = false


# This method is called when the player ends the VR experience
func _on_xr_ended() -> void:
	# Pause the game
	get_tree().paused = true
