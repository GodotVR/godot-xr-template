extends Node3D

@export var saved_material : Material

# We only allow saving once after our scene loads
var is_saved = false

func _on_save_button_button_pressed(_button):
	if !is_saved:
		# Save our spawn point name
		WorldData.instance.set_value("spawn_point_name", name)

		# Get auto save name
		var auto_save_name = WorldData.instance.get_value("auto_save_name")
		if !auto_save_name:
			# First time saving? Determine this name
			var date = Time.get_datetime_dict_from_system()
			auto_save_name = "auto_save_%d-%d-%d" % [ date["year"], date["month"], date["day"] ]
			WorldData.instance.set_value("auto_save_name", auto_save_name)

		# Should give our auto save a nice summary...
		var summary : String = auto_save_name
		if !WorldData.instance.save_file(auto_save_name, summary):
			return

		# Change button to saved
		$Pole/SaveButton/Button.set_surface_override_material(0, saved_material)
		is_saved = true
