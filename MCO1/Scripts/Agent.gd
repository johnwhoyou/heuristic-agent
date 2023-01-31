extends Node2D

signal agent_scanned
signal agent_rotated
signal agent_moved(agent_pos)

var rng = RandomNumberGenerator.new()
var past_states = []

enum FACINGS {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

var state = {
	"facing": FACINGS.EAST,
	"pos": Vector2.ZERO,
	"scan": null,
	"m": null
}

func _ready():
	# Set camera
	$Camera2D.current = true
	# Connect emittable signals to parent
	var source = get_node(".") 
	source.connect("agent_moved", get_parent(), "_on_agent_move")
	source.connect("agent_scanned", get_parent(), "_on_agent_scan")
	source.connect("agent_rotated", get_parent(), "_on_agent_rotate")
	# Seed rng
	rng.randomize()

func simulate(action):
	if action == "move" and move_is_valid():
		agent_move()
	if action == "scan": 
		agent_scan()
	if action == "rotate":
		agent_rotate()

func random_search():
	var num = rng.randi_range(0, 2)
	match num:
		0: simulate("move")
		1: simulate("scan")
		2: simulate("rotate")

func smart_search():
	var tiles_h = []
	var tiles_f = []
	# Get heuristics for all neighbors
	for i in range(4):
		simulate("scan")
		if state.scan != null:
			if state.scan.is_in_group("gold"):
				simulate("move")
				break
			elif state.scan.is_in_group("pit"):
				continue
		var h = next_move_manhattan()
		tiles_h.append(h)
		tiles_f.append(state.facing)
		print(tiles_h)
		print(tiles_f)
		simulate("rotate")
	# move if there is a valid neighbor
	if tiles_h and tiles_f:
		# find smallest manhattan distance among all neighbors
		var index = get_min_index(tiles_h)
		while state.facing != tiles_f[index]:
			simulate("rotate")
		# Move if agent is not yet in gold tile
		if (state.pos != Global.gold_tile):
			simulate("move")
	else: # when there is no "safe" neighbor, just move forcefully 
		simulate("move")

func agent_scan():
	var objectives = Global.objectives
	var n = Global.n
	var scan = null
	if state.facing == FACINGS.EAST:
		for i in range(state.pos.x, n):
			if Vector2(i, state.pos.y) in objectives:
				scan = objectives[Vector2(i, state.pos.y)]
				break
	elif state.facing == FACINGS.WEST:
		for i in range(state.pos.x, 0, -1):
			if Vector2(i, state.pos.y) in objectives:
				scan = objectives[Vector2(i, state.pos.y)]
				break
	elif state.facing == FACINGS.NORTH:
		for i in range(state.pos.y, 0, -1):
			if Vector2(state.pos.x, i) in objectives:
				scan = objectives[Vector2(state.pos.x, i)]
				break
	elif state.facing == FACINGS.SOUTH:
		for i in range(state.pos.y, n):
			if Vector2(state.pos.x, i) in objectives:
				scan = objectives[Vector2(state.pos.x, i)]
				break
	state.scan = scan
	print("Scan return: %s" %scan)
	emit_signal("agent_scanned")

func agent_rotate():
	# Change facings when agent_rotate() is called
	if state.facing == FACINGS.EAST:
		state.facing = FACINGS.SOUTH
		$Sprite.rotation_degrees = 90
	elif state.facing == FACINGS.SOUTH:
		state.facing = FACINGS.WEST
		$Sprite.rotation_degrees = 0
		$Sprite.flip_h = true
	elif state.facing == FACINGS.WEST:
		state.facing = FACINGS.NORTH
		$Sprite.rotation_degrees = -90
		$Sprite.flip_h = false
	elif state.facing == FACINGS.NORTH:
		state.facing = FACINGS.EAST
		$Sprite.rotation_degrees = 0
	emit_signal("agent_rotated")

func agent_move():
	# Move agent based on facings
	if state.facing == FACINGS.EAST:
		state.pos.x += 1
		position = state.pos * 47
	elif state.facing == FACINGS.WEST:
		state.pos.x -= 1
		position = state.pos * 47
	elif state.facing == FACINGS.NORTH:
		state.pos.y -= 1
		position = state.pos * 47
	elif state.facing == FACINGS.SOUTH:
		state.pos.y += 1
		position = state.pos * 47
	emit_signal("agent_moved", state.pos)

func move_is_valid():
	if state.facing == FACINGS.NORTH and state.pos.y - 1 >= 0:
		return true
	elif state.facing == FACINGS.SOUTH and state.pos.y + 1 < Global.n:
		return true
	elif state.facing == FACINGS.EAST and state.pos.x + 1 < Global.n:
		return true
	elif state.facing == FACINGS.WEST and state.pos.x - 1 >= 0:
		return true
	return false

func get_manhattan(pos):
	return abs(pos.x - Global.gold_tile.x) + abs(pos.y - Global.gold_tile.y)

func next_move_manhattan():
	var temp = state.pos
	if state.facing == FACINGS.EAST:
		temp.x += 1
	elif state.facing == FACINGS.WEST:
		temp.x -= 1
	elif state.facing == FACINGS.NORTH:
		temp.y -= 1
	elif state.facing == FACINGS.SOUTH:
		temp.y += 1
	print(get_manhattan(temp))
	return get_manhattan(temp)

func get_min_index(list):
	var min_index = 0
	for i in range(list.size()):
		if list[min_index] > list[i]:
			min_index = i
	return min_index
