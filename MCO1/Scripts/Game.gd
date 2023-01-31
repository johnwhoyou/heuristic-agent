extends Node2D

var tile = preload("res://Scenes/Tile.tscn")
var pit = preload("res://Scenes/PitTile.tscn")
var beacon = preload("res://Scenes/BeaconTile.tscn")
var gold = preload("res://Scenes/GoldTile.tscn")
var agent = preload("res://Scenes/Agent.tscn")

onready var dashboard = $CanvasLayer/HUD/Dashboard

var scan_count = 0
var rotate_count = 0
var move_count = 0
var backtracks = 0


func _ready():
	setup_simulation()
	# Add agent
	var a = agent.instance()
	a.position = Vector2(0, 0) * 47
	a.state["pos"] = Vector2(0, 0)
	add_child(a)
	# Manipulate HUD
	$CanvasLayer/HUD/Dashboard.modulate = Color(0, 0, 0)

func setup_simulation():
	# Generate tiles
	for i in range(0, Global.n):
		for j in range(0, Global.n):
			var t = tile.instance()
			t.position = Vector2(i, j) * 47
			t.pos = Vector2(i, j)
			add_child(t)
			Global.tile_grid[Vector2(i, j)] = t
	# Calculate number of pits and beacon
	var pit_num  = floor(Global.n * 0.25)
	var beacon_num = floor(Global.n * 0.1) if floor(Global.n * 0.1) >= 1 else 1.0
	# Generate pits
	randomize()
	for _i in range(0, pit_num):
		var p = pit.instance()
		var coords = Vector2(floor(rand_range(1, Global.n)), floor(rand_range(1, Global.n)))
		while coords in Global.objectives:
			coords = Vector2(floor(rand_range(1, Global.n)), floor(rand_range(1, Global.n)))
		p.position = coords * 47
		p.pos = coords
		add_child(p)
		Global.objectives[coords] = p
	# Generate gold tile
	Global.gold_tile = Vector2(floor(rand_range(1, Global.n)), floor(rand_range(1, Global.n)))
	while Global.gold_tile in Global.objectives:
		Global.gold_tile = Vector2(floor(rand_range(1, Global.n)), floor(rand_range(1, Global.n)))
	var g = gold.instance()
	g.position = Global.gold_tile * 47
	g.pos = Global.gold_tile
	add_child(g)
	Global.objectives[Global.gold_tile] = g
	# Generate beacon
	for _i in range(0, beacon_num):
		var b = beacon.instance()
		var coords = Vector2(floor(rand_range(1, Global.n)), floor(rand_range(1, Global.n)))
		while coords in Global.objectives:
			coords = Vector2(floor(rand_range(1, Global.n)), floor(rand_range(1, Global.n)))
		b.position = coords * 47
		b.pos = coords
		b.m = abs(b.pos.x - Global.gold_tile.x) + abs(b.pos.y - Global.gold_tile.y)
		add_child(b)
		Global.objectives[coords] = b
	# Set starting tile as visited
	Global.tile_grid[Vector2(0, 0)].set_visited()

func iterate_simulation():
	if !Global.game_over:
		if Global.algorithm == "random":
			$Agent.random_search()
		else:
			$Agent.smart_search()
	
func run_simulation():
	while !Global.game_over:
		if Global.algorithm == "random":
			$Agent.random_search()
		else:
			$Agent.smart_search()

func _on_agent_scan():
	scan_count += 1
	$CanvasLayer/HUD/Dashboard/VBoxContainer/Scans.text = "Scans: %s" %scan_count

func _on_agent_rotate():
	rotate_count += 1
	$CanvasLayer/HUD/Dashboard/VBoxContainer/Rotates.text = "Rotates: %s" %rotate_count

func _on_agent_move(agent_pos):
	move_count += 1
	$CanvasLayer/HUD/Dashboard/VBoxContainer/Moves.text = "Moves: %s" %move_count
	print("Agent move: %s" %agent_pos)
	if Global.tile_grid[agent_pos].visited == true:
		backtracks += 1
		$CanvasLayer/HUD/Dashboard/VBoxContainer/Backtracks.text = "Backtracks: %s" %backtracks
	else:
		Global.tile_grid[agent_pos].set_visited()
	# Check if agent has moved onto an objective square
	if agent_pos in Global.objectives:
		var objective = Global.objectives[agent_pos]
		if objective.is_in_group("pit"):
			print("PitTile hit!")
			Global.game_over = true
		elif objective.is_in_group("beacon"):
			print("Beacon hit!")
			$Agent.state.m = objective.m
		elif objective.is_in_group("gold"):
			print("GoldTile hit!")
			Global.game_over = true
