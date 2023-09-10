extends WorldData

## Game State Singleton
##
## This auto-load class can be used to hold game state information between
## levels. This class can be accessed from any script using its global
## GameState name.

## Game difficulty options
enum GameDifficulty {
	GAME_EASY,
	GAME_NORMAL,
	GAME_HARD,
	GAME_MAX
}

## Game difficulty lets us set the difficulty of the game.
@export var game_difficulty : GameDifficulty = GameDifficulty.GAME_NORMAL:
	set(value):
		if value < 0 or value >= GameDifficulty.GAME_MAX:
			push_warning("Difficulty %d is out of bounds" % [ value ])
			return

		game_difficulty = value
		set_value("game_difficulty", game_difficulty)

func get_current_zone_id() -> String:
	var zone_id = get_value("current_zone_id")
	if zone_id:
		return zone_id

	return ""

func get_spawn_point_name() -> String:
	var zone_id = get_value("spawn_point_name")
	if zone_id:
		return zone_id

	return ""

## Create a new game and set default settings
func new_game_state():
	# Clear out whatever is in our world data.
	WorldData.instance.clear_all()

	var date = Time.get_datetime_dict_from_system()

	game_difficulty = GameDifficulty.GAME_NORMAL

## Save our game state
func save_game_state(p_name : String) -> bool:
	# For now we just set our summary to our save name
	# but you can store whatever you want here to show
	# in our load selection screen.
	var summary : String = p_name

	return save_file(p_name, summary)

## Load our game state
func load_game_state(p_name : String) -> bool:
	# Make sure we clear out stuff
	new_game_state()

	if !load_file(p_name):
		return false

	# Get data from our world data object to ensure it's sanitised
	game_difficulty = get_value("game_difficulty")

	return true

func _init():
	super._init("")
