extends KinematicBody2D

export(int) var MOVE_SPEED = 60
export(int) var MOVE_ACCEL = 40
export(int) var MOVE_FRICTION = 70
export(float) var ROTATE_ACCEL = 0.15
export(float) var DEADZONE = 0.25
export(bool) var CAN_SHOOT = true
export(float) var SHOOT_COOLDOWN = 0.25
export(bool) var BARREL_IS_LOCKED = false
export(int) var BULLET_BOUNCES = 0
export(bool) var IS_ENEMY_TANK = false
export(int) var ROT_THRESHOLD = deg2rad(90)

var ls_input = Vector2.ZERO # LEFT STICK
var rs_input = Vector2.ZERO # RIGHT STICK
var velocity = Vector2.ZERO
var barrel_angle = 0

const Bullet = preload("res://Entities/Bullet.tscn")
const SootSprite = preload("res://Effects/SootSprite.tscn")

onready var barrel = $Barrel
onready var barrel_raycast = $Barrel/RayCast2D
onready var timer = $Timer
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var shoot_sound_player = $ShootSoundPlayer

enum {
	IDLE,
	PATROL,
	WANDER,
	SHOOT
}

enum {
	COUNTERCLOCKWISE = -1,
	CLOCKWISE = 1
}

func _physics_process(delta):
	move_and_rotate(delta)
	sync_animation_speed()

	
func move_and_rotate(delta):
	if ls_input.length() >= DEADZONE:
		# check if the input angle is more than 90 deg away from current rotations
		var angle_out_of_range = abs(angle2vector(global_rotation).angle_to(ls_input)) >= deg2rad(90)

		print(rad2deg(ls_input.angle()))
	
		if velocity.length() <= MOVE_SPEED / 4:
			var offset = get_vector_orientation(global_rotation, ls_input) * ROTATE_ACCEL
			if angle_out_of_range:
				rotate_body(angle2vector(global_rotation + offset), delta)	
			if velocity == Vector2.ZERO:
				velocity = angle2vector(global_rotation + offset) * MOVE_SPEED / 10
#		else:
		velocity = velocity.move_toward(ls_input * MOVE_SPEED, MOVE_ACCEL * delta)
		rotate_body(velocity, delta)
			
	else:
		velocity = velocity.move_toward(Vector2.ZERO, MOVE_FRICTION * delta)
	
	rotate_barrel(rs_input, delta)
	move_and_collide(velocity * delta)
	
func rotate_body(angle_vector, delta):
	var prev_angle = global_rotation
	global_rotation = angle_vector.angle()
	if !BARREL_IS_LOCKED:
		var rot_angle = barrel.global_rotation - (global_rotation - prev_angle)
		rotate_barrel(angle2vector(rot_angle), delta)
	
func rotate_barrel(angle_vector, delta):
	if !BARREL_IS_LOCKED:
		if angle_vector.length() >= DEADZONE:
			barrel.global_rotation = angle_vector.angle()
			get_vector_orientation(global_rotation, angle_vector)
			# TODO: implement barrel rotation velocity / acceleration 
			
func shoot(cooldown = SHOOT_COOLDOWN):
	if(CAN_SHOOT):
		var direction = barrel.global_rotation
		var direction_vector = Vector2(cos(direction), sin(direction))
		var bullet = Bullet.instance()
		bullet.init(direction_vector, global_position + (direction_vector * 16), BULLET_BOUNCES, IS_ENEMY_TANK, modulate)
		get_parent().add_child(bullet)
		
		shoot_sound_player.play()
		animation_player.play("Barrel_Fire")
		
		CAN_SHOOT = false
		timer.start(cooldown)
		
func sync_animation_speed():
	var time_scale = 0.0
	
	if velocity.length() > 0:
		time_scale = velocity.length() / MOVE_SPEED
	
	animation_tree.set("parameters/TimeScale/scale", time_scale)
	
func get_vector_orientation(angle, target_vector):
	# returns -1 if vector is counterclockwise of body's rotation
	# returns 1 if vector is clockwise of body's rotation
	var origin_vector = angle2vector(angle)
	if (origin_vector.y * target_vector.x > origin_vector.x * target_vector.y):
		return COUNTERCLOCKWISE
	else:
		return CLOCKWISE
	pass
	
func angle2vector(angle):
	return Vector2(cos(angle), sin(angle))
	
func rotate_smoothly(output_angle):
	var new_angle = output_angle
	if output_angle <= deg2rad(-180):
		new_angle = -output_angle
		
	return new_angle
		
	
func death():
	var sootSprite = SootSprite.instance()
	sootSprite.global_position = global_position
	get_parent().add_child(sootSprite)
	get_parent().move_child(sootSprite, 0)
	queue_free()

func _on_Timer_timeout():
	CAN_SHOOT = true


func _on_Hurtbox_area_entered(area):
	death()
