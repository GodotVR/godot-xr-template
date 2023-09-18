class_name PersistentWorld
extends Node


## Persistent World Data Object
##
## The [PersistentWorld] object holds information about the world. This
## information can be stored to encrypted save-files, and then loaded back at
## a later time.
##
## It's assumed this (or an extended script) is instanced as a singleton,
## preferably as an autoloaded script.
##
## Multiple instances of [PersistentWorld] objects can be created - for example
## to inspect other saved games without affecting the main instance.


## Signal invoked before loading world-data
signal world_loading

## Signal invoked after loading world-data
signal world_loaded

## Signal invoked before saving world-data
signal world_saving

## Signal invoked after saving world-data
signal world_saved


## Static instance of the world data
static var instance : PersistentWorld = null


@export_group("Persistence Settings")

## Password for encrypted save files
@export var save_file_password := ""

## Database of all persistent zones in the game
@export var zone_database : PersistentZoneDatabase

## Database of all persistent item types in the game
@export var item_database : PersistentItemDatabase


# World data dictionary
var _data := {}

# Mutex protecting data
var _mutex := Mutex.new()


# Check for configuration issues on this node
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Check for blank password
	if save_file_password == "":
		warnings.append("Save password not set - saves will be unencrypted")

	# Check for zone database
	if not zone_database:
		warnings.append("Zone database not set")

	# Check for item database
	if not item_database:
		warnings.append("Item database not set")

	# Return warnings
	return warnings



## This method creates a unique ID starting with [param base] follwed by a
## random number. The [param value] is stored using this ID, and the ID is
## returned to the caller.
func set_unique(base : String, value : Variant) -> String:
	# Lock while trying to create the ID
	_mutex.lock()

	# Loop generating random IDs until we find a free one
	var id : String
	while true:
		id = base + str(randi() % 999999)
		if not _data.has(id):
			break

	# Save the value under the ID, then return the ID
	_data[id] = value
	_mutex.unlock()
	return id


## This method saves the [param value] under the [param id].
func set_value(id : String, value : Variant) -> void:
	_mutex.lock()
	_data[id] = value
	_mutex.unlock()


## This method gets the value stored under the [param id]. If the [param id]
## does not exist then the [param default] value is returned.
func get_value(id : String, default : Variant = null): # -> Variant
	_mutex.lock()
	var value = _data.get(id, default)
	_mutex.unlock()
	return value


## This method clears a value under the [param id].
func clear_value(id : String) -> void:
	_mutex.lock()
	_data.erase(id)
	_mutex.unlock()


## This method clears all values matching the glob [param pattern]. See 
## [method String.match] for pattern matching rules.
func clear_matching(pattern : String) -> void:
	_mutex.lock()
	for _key in _data.keys():
		var key : String = _key
		if key.match(pattern):
			_data.erase(key)
	_mutex.unlock()


## This method clears all values.
func clear_all() -> void:
	_mutex.lock()
	_data.clear()
	_mutex.unlock()


## This method loads the summary information for the saved world-data
## associated with the specified [param file_name]. If the world-data does
## not exist then this method returns null.
func load_summary(file_name : String) -> Variant:
	# Open the world-data save file for reading
	var file := _open_file(file_name, FileAccess.READ)
	if not file:
		return null

	# Read the summary
	var summary = file.get_var()
	file.close()

	# Return the summary
	return summary


## This method loads the world-data associated with the specified
## [param file_name]. If the world-data does not exist or is invalid then
## this method returns false.
func load_file(file_name : String) -> bool:
	# Report start of world-data loading
	world_loading.emit()

	# Open the world-data save file for reading
	var file := _open_file(file_name, FileAccess.READ)
	if not file:
		return false

	# Skip the summary
	file.get_var()

	# Read the data
	var new_data = file.get_var()
	file.close()

	# Skip if not dictionary
	if not new_data is Dictionary:
		return false

	# Use the new data
	_mutex.lock()
	_data = new_data
	_mutex.unlock()

	# Report world-data loaded
	world_loaded.emit()

	# Report success
	return true


## This method saves the world-data under the specified [param file_name].
## If the  save fails then this method returns false. The [param file_name]
## string must be a legal part of a file name.
func save_file(file_name : String, summary : Variant) -> bool:
	# Report start of world-data saving
	world_saving.emit()

	# Open the world-data save file for writing
	var file := _open_file(file_name, FileAccess.WRITE)
	if not file:
		return false

	# Write the summary
	file.store_var(summary)

	# Write the data
	_mutex.lock()
	file.store_var(_data)
	_mutex.unlock()

	# Close the file
	file.close()

	# Report world-data saved
	world_saved.emit()
	return true


## This method deletes the world-data associated with the specified
## [param file_name]. If the world-data does not exist then this method
## returns false.
static func delete_file(file_name : String) -> bool:
	# Construct the file name
	var file_path := "user://save_%s.data" % file_name

	# Remove the file
	return DirAccess.remove_absolute(file_path) == OK


## This method returns a list of the names of all the saved world-data
## instances.
func list_saves() -> Array[String]:
	# Construct the return list
	var ret : Array[String] = []

	# Build a regular expression to match save file names
	var regex := RegEx.new()
	regex.compile("^save_(?<name>.*)\\.data$")

	# Process all files in the user folder
	for file in DirAccess.get_files_at("user://"):
		var result := regex.search(file)
		if result:
			ret.append(result.get_string("name"))

	# Return the save files
	return ret


# Open a world-data save file.
func _open_file(file_name : String, mode : FileAccess.ModeFlags) -> FileAccess:
	# Construct the file name
	var file_path := "user://save_%s.data" % file_name

	# Warn about unencrypted save files for debugging
	if save_file_password == "":
		push_warning("Unencrypted save file: ", file_path)
		return FileAccess.open(file_path, mode)

	# Handle encrypted file with password
	return FileAccess.open_encrypted_with_pass(file_path, mode, save_file_password)
