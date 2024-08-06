class_name Player
extends Node3D

# Amount of time in seconds between ticks (movement).
const DEFAULT_TICK_RATE : float = 0.25

# The internal handle used by this player, so we can map controls accordingly.
@export var player_handle : String = "p1"

# How often the player places track per second (aka speed).
@export var tick_rate : float = DEFAULT_TICK_RATE

# The direction the tracks are currently being placed in.
@export var facing : Vector2 = Vector2.LEFT

# The size of the track, for calculating positioning of the next pieces.
@export var track_size : float = 1.0

# The scenes to use when laying pieces of track.
var track_straight : PackedScene = preload("res://track_straight.tscn")
var track_corner : PackedScene = preload("res://track_corner.tscn")

# This is where we'll be trying to face on the next tick.
var next_facing: Vector2 = facing

# The time that has passed since the last tick, used internally to calculate
# when a tick has occurred.
var time_since_last_tick : float = 0.0

# An ordered list of all the track pieces for this player.
var track : Array[Node3D] = []

# The maximum track length.  Depending on the game rules, players may need to
# collect items in-game to increase their track (and therefore train) size.
var track_max_length : int = 1000

# Wether or not the player is currently alive or not.
var is_alive : bool = true

func _process(delta):
	if is_alive:
		handle_player_input()
		move_when_ready(delta)


func handle_player_input():
	if Input.is_action_just_pressed(player_handle + "_left"):
		rotate_next_facing(-90)
	if Input.is_action_just_pressed(player_handle + "_right"):
		rotate_next_facing(90)


func move_when_ready(delta: float):
	# Use the delta time to deterine if we're going to make another move yet or not.
	time_since_last_tick += delta
	if time_since_last_tick >= tick_rate:
		time_since_last_tick -= tick_rate
		
		# TODO: Check if we've collided with something, if so mark us as dead, otherwse continue.
		move()


func move():
	# Update our position.
	position.x += round(next_facing.x * track_size)
	position.z += round(next_facing.y * track_size)
	
	remove_last_track()
	maybe_swap_for_corner()
	place_next_track()
	
	# Update our facing to our new facing.
	facing = next_facing


func remove_last_track():
	if track.size() >= track_max_length && track.size() > 1:
		track[0].queue_free()
		track.remove_at(0)	


func maybe_swap_for_corner():
	# We only need to swap for a corner if we're turning.
	if facing != next_facing and track.size() > 0:
		# Record the position of the current track piece then delete it.
		var current_position = track[-1].position
		track[-1].queue_free()
		
		# Add the replacement piece of track.
		var current_track = track_corner.instantiate() as Node3D
		$Track.add_child(current_track)
		track[-1] = current_track
		current_track.position = current_position
		
		# Rotate the corner piece so it correctly links the two adjacent track pieces.
		if track.size() > 1:
			rotate_to_join(current_track, track[-2].position, position)


func rotate_to_join(node: Node3D, previous: Vector3, next: Vector3):
	var current : Vector3 = node.position
	
	# Going UP from going left or right.
	if next.z < current.z:
		if previous.x > current.x:
			node.rotate_y(deg_to_rad(90))
		else:
			node.rotate_y(deg_to_rad(180))
	
	# Going DOWN from going left or right.
	if next.z > current.z:
		if previous.x < current.x:
			node.rotate_y(deg_to_rad(-90))
	
	# Going LEFT from going up or down.
	if next.x < current.x:
		if previous.z > current.z:
			node.rotate_y(deg_to_rad(-90))
		else:
			node.rotate_y(deg_to_rad(180))
	
	# Going RIGHT from going up or down.
	if next.x > current.x:
		if previous.z < current.z:
			node.rotate_y(deg_to_rad(90))


func place_next_track():
	var new_track = track_straight.instantiate() as Node3D
	$Track.add_child(new_track)
	track.append(new_track)
	new_track.position = position
	
	# If we're going to face in the Y axis, rotate the track accordingly.
	if abs(next_facing.y) > 0.1:
		new_track.rotate_y(deg_to_rad(90))


func rotate_next_facing(degrees: int):
	var potential_next_facing = next_facing.rotated(deg_to_rad(degrees))
	if facing.distance_to(potential_next_facing) < 1.9:
		next_facing = potential_next_facing
