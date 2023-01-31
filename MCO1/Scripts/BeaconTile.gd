extends Node2D


var pos = Vector2.ZERO
var m = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("beacon")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
