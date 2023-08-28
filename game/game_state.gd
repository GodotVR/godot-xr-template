extends Node


## Game State Singleton
##
## This auto-load class can be used to hold game state information between
## levels. This class can be accessed from any script using its global
## GameState name.


func _init():
	# Construct a WorldData to use
	WorldData.instance = WorldData.new("")
