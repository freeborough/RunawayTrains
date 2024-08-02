extends Node

var player : PackedScene = preload("res://player.tscn")

var number_of_players : int = 2
var players : Array[Player] = []


func _ready():
	spawn_players()


func _process(delta):
	check_for_quit()


func spawn_players():
	for i in number_of_players:
		# Instantiate a new Player.
		var new_player = player.instantiate() as Player
		players.append(new_player)
		get_tree().current_scene.add_child(new_player)
		
		# Initialise the new Player.
		new_player.player_handle = "p%s" % (i + 1)
		new_player.position = Vector3(0, 0, i * 4)
		new_player.facing = Vector2(-1, 0)


func check_for_quit():
	# TODO: Replace with a proper game menu, support for all controllers pressing START, etc.
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
