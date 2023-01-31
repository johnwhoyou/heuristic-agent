extends Node

enum FACINGS {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

var algorithm = "random"
var game_over = false
var tile_grid = {}
var objectives = {}
var gold_tile = Vector2.ZERO
var n = 8
