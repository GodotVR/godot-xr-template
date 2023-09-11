extends PersistentWorld


## Game State Singleton
##
## This auto-load class can be used to hold game state information between
## levels. This class can be accessed from any script using its global
## GameState name.
##
## The [GameStaging] script populates the staging and current_zone fields
## of this script in response to scene switching.


## Game difficulty options
enum GameDifficulty {
	GAME_EASY,
	GAME_NORMAL,
	GAME_HARD,
	GAME_MAX
}


@export_group("Game Settings")

## This property sets the starting zone for the game
@export var starting_zone : PersistentZoneInfo

## This property sets the difficulty of the game.
@export var game_difficulty : GameDifficulty = GameDifficulty.GAME_NORMAL:
	set = _set_game_difficulty


## Current zone (when playing game)
var current_zone : PersistentZone


func _ready():
	# Use this game state as the global world state
	instance = self


## This method starts a new game.
func new_game(difficulty := GameDifficulty.GAME_NORMAL) -> bool:
	# Clear game data and start with requested difficulty level
	clear_all()
	game_difficulty = difficulty

	# Load the initial world state (starting zone)
	return load_world_state()


## This method loads a game from the specified save-game.
func load_game(p_name : String) -> bool:
	# Read data from the save-game file
	if not load_file(p_name):
		return false

	# Load the world state from the data
	return load_world_state()


## This method saves the current game-state to memory then quits to the main
## menu. It's possible to restore the previous game state by calling 
## [method load_world_state].
func quit_game() -> bool:
	# Save the world state to memory in case we want to resume
	if not save_world_state():
		return false

	# Exit to the main menu
	current_zone.exit_to_main_menu()
	return true


## This method auto-saves the current game state to disk.
func auto_save_game() -> bool:
	# Save the world state
	if not save_world_state():
		return false

	# Get auto save name
	var auto_save_name = get_value("auto_save_name")
	if !auto_save_name:
		# First time saving? Determine this name
		var date = Time.get_datetime_dict_from_system()
		auto_save_name = "auto_save_%d-%d-%d" % [ date["year"], date["month"], date["day"] ]
		set_value("auto_save_name", auto_save_name)

	# Should give our auto save a nice summary...
	var summary : String = auto_save_name
	return save_file(auto_save_name, summary)


## This method saves the world-state to the [PersistentWorld] system.
func save_world_state() -> bool:
	# Fail if not in a zone
	if not PersistentStaging.instance or not current_zone:
		return false

	# Fail if no player body
	var body := XRToolsPlayerBody.find_instance(current_zone)
	if not body:
		return false

	# Save the current zone-state, difficulty, and spawn-info
	current_zone.save_world_state()
	set_value("game_difficulty", game_difficulty)
	set_value("current_zone_id", current_zone.zone_info.zone_id)
	set_value("current_location", body.global_transform)
	return true


## This method restores the world-state from the [PersistentWorld] system.
func load_world_state() -> bool:
	# Fail if no staging
	if not PersistentStaging.instance:
		return false

	# Get the zone ID
	var zone_id = get_value("current_zone_id")
	if not zone_id is String:
		# Default to the starting zone
		zone_id = starting_zone.zone_id

	# Get the location
	var location = get_value("current_location")
	if not location is Transform3D:
		# Default to null (spawn location in level)
		location = null

	# Restore the game difficulty
	game_difficulty = get_value("game_difficulty")

	# Get the zone
	var zone := zone_database.get_zone(zone_id)
	if not zone:
		return false

	# Start transition to scene
	PersistentStaging.instance.load_scene(zone.instance_scene, location)
	return true


# Handle changing the game difficulty
func _set_game_difficulty(p_game_difficulty : GameDifficulty) -> void:
	if p_game_difficulty < 0 or p_game_difficulty >= GameDifficulty.GAME_MAX:
		push_warning("Difficulty %d is out of bounds" % [ p_game_difficulty ])
		return

	game_difficulty = p_game_difficulty
	set_value("game_difficulty", game_difficulty)
