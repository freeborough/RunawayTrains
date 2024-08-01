extends Node3D

# Amount of time in seconds between ticks (movement).
const DEFAULT_TICK_RATE : float = 0.5

# The internal handle used by this player, so we can map controls accordingly.
@export var player_handle : String = "p1"

# How often the player places track per second (aka speed).
@export var tick_rate : float = DEFAULT_TICK_RATE

# The direction the tracks are currently being placed in.
@export var facing : Vector2 = Vector2.LEFT

# The size of the track, for calculating positioning of the next pieces.
@export var track_size : float = 1.0

# The scenes to use when laying pieces of track.
var track_straight : PackedScene = load("res://track_straight.tscn")
var track_corner : PackedScene = load("res://track_corner.tscn")

# This is where we'll be trying to face on the next tick.
var next_facing: Vector2 = facing

# The time that has passed since the last tick, used internally to calculate
# when a tick has occurred.
var time_since_last_tick : float = 0.0

# An ordered list of all the track pieces for this player.
var track : Array[Node3D] = []

# The maximum track length.  Depending on the game rules, players may need to
# collect items in-game to increase their track (and therefore train) size.
var track_max_length : int = 10

# Count of the number of collisions in the next track location.
var collision_count : int = 0

# Wether or not the player is currently alive or not.
var is_alive : bool = true

func _process(delta):
	check_for_quit()
	if is_alive:
		handle_player_input()
		move_collider()
		move_when_ready(delta)


func check_for_quit():
	# TODO: Replace with a proper game menu at some point.
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func handle_player_input():
	if Input.is_action_just_pressed(player_handle + "_left"):
		rotate_next_facing(-90)
	if Input.is_action_just_pressed(player_handle + "_right"):
		rotate_next_facing(90)


func move_collider():
	$NextLocation.position.x = round(next_facing.x * track_size)
	$NextLocation.position.z = round(next_facing.y * track_size)


func move_when_ready(delta: float):
	# Use the delta time to deterine if we're going to make another move yet or not.
	time_since_last_tick += delta
	if time_since_last_tick >= tick_rate:
		time_since_last_tick -= tick_rate
		
		# Check if we've collided with something, if so mark us as dead, otherwse continue.
		if collision_count > 0:
			is_alive = false
		else:
			move()


func move():
	# Update our position.
	position.x += round(next_facing.x * track_size)
	position.z += round(next_facing.y * track_size)
	
	# Remove the last piece of track.
	if track.size() >= track_max_length && track.size() > 1:
		track[0].queue_free()
		track.remove_at(0)
	
	# Replace the previous piece of track with a corner if we've turned.
	if facing != next_facing and track.size() > 0:
		var previous_position = track[-1].position
		track[-1].queue_free()
		var previous_track = track_corner.instantiate() as Node3D
		$Track.add_child(previous_track)
		track[-1] = previous_track
		previous_track.position = previous_position
	
	# Place the next piece of track.
	var new_track = track_straight.instantiate() as Node3D
	$Track.add_child(new_track)
	track.append(new_track)
	new_track.position = position
	
	# Update our facing to our new facing.
	facing = next_facing


func rotate_next_facing(degrees: int):
	var potential_next_facing = next_facing.rotated(deg_to_rad(degrees))
	if facing.distance_to(potential_next_facing) < 1.9:
		next_facing = potential_next_facing


func _on_next_location_body_entered(_body):
	collision_count += 1


func _on_next_location_body_exited(_body):
	collision_count -= 1
