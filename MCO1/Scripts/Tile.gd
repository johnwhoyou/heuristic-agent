extends Node2D

var pos = Vector2.ZERO
var visited = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_visited():
	$Sprite.modulate = Color(0, 0, 1)
	visited = true