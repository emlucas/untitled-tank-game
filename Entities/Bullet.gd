extends KinematicBody2D

export(int) var SPEED = 150
export(float) var REFLECT_FRICTION = 0.8
export(bool) var IS_ENEMY_BULLET
var num_bounces = 1
var velocity = Vector2.ZERO

onready var audio_player = $AudioStreamPlayer

func init(direction_vector, pos, bounce, is_enemy_bullet, bullet_color):
	velocity = direction_vector * SPEED
	global_position = pos
	global_rotation = velocity.angle()
	num_bounces = bounce
	
	modulate = bullet_color
	
	var hitbox = $Hitbox
	match is_enemy_bullet:
		true:
			hitbox.set_collision_mask_bit(2, 1)
		false:
			hitbox.set_collision_mask_bit(4, 1)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		if num_bounces <= 0:
			bullet_destroyed()
		else:
			num_bounces -= 1
			var reflect = collision.remainder.bounce(collision.normal)
			velocity = velocity.bounce(collision.normal) * REFLECT_FRICTION
			move_and_collide(reflect)
			audio_player.play()

func bullet_destroyed():
	queue_free()

func _on_Hitbox_area_entered(area):
	bullet_destroyed()
