extends Node3D

@export var saved_material : Material

# We only allow saving once after our scene loads
var is_saved = false

func _on_save_button_button_pressed(_button):
	# Skip if already saved
	if is_saved:
		return

	# Auto-save the game
	if not GameState.auto_save_game():
		return

	# Change button to saved
	$Pole/SaveButton/Button.set_surface_override_material(0, saved_material)
	is_saved = true
