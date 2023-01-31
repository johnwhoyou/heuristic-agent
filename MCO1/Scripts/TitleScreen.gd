extends Control

onready var board_size_label = get_node("Selection/HBoxContainer/BoardSize")

func _on_Start_button_down():
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_AIBtn1_button_down():
	Global.algorithm = "random"

func _on_AIBtn2_button_down():
	Global.algorithm = "smart"

func _on_BoardBtn1_button_down():
	Global.n -= 8
	if Global.n < 8:
		Global.n = 8
	board_size_label.text = "  %s  " %Global.n

func _on_BoardBtn2_button_down():
	Global.n += 8
	if Global.n > 256:
		Global.n = 256
	board_size_label.text = "  %s  " %Global.n
