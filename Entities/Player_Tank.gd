extends "res://Entities/Tank.gd"

export(int) var FIRE_LINE_LENGTH = 200
export(Vector2) var origin = Vector2.ZERO

const CROSSHAIR_GAP = 8

onready var fire_line = $Barrel/fire_line
onready var crosshair = $Barrel/fire_line/crosshair

func _physics_process(delta):
	get_inputs()
	draw_aim()
	
func get_inputs():
	# GET LEFT STICK INPUTS
	var ls_horizontal = Input.get_action_strength("ls_right") - Input.get_action_strength("ls_left")
	var ls_vertical = Input.get_action_strength("ls_down") - Input.get_action_strength("ls_up")

	ls_input = Vector2(ls_horizontal, ls_vertical).clamped(1)
	
	# GET RIGHT STICK INPUTS
	var rs_horizontal = Input.get_action_strength("rs_right") - Input.get_action_strength("rs_left")
	var rs_vertical = Input.get_action_strength("rs_down") - Input.get_action_strength("rs_up")

	rs_input = Vector2(rs_horizontal, rs_vertical).clamped(1)
	
	# SHOOT
	if Input.is_action_pressed("shoot"):
		shoot()

func draw_aim():
	if barrel_raycast.is_colliding():
		var distance_to_collision = (global_position - barrel_raycast.get_collision_point()).length()
		fire_line.region_rect.size.y = distance_to_collision - CROSSHAIR_GAP
		crosshair.visible = true
		
	elif fire_line.region_rect.size.y != FIRE_LINE_LENGTH:
		fire_line.region_rect.size.y = FIRE_LINE_LENGTH
		crosshair.visible = true
		
	crosshair.position.y = fire_line.region_rect.size.y + CROSSHAIR_GAP
	crosshair.global_rotation = 0
