extends "res://Entities/Tank.gd"

onready var player_detection = $PlayerDetection

var state = IDLE

func _ready():
	IS_ENEMY_TANK = true

func _physics_process(delta):
	match state:
		IDLE:
			idle_state(delta)
		PATROL:
			pass
		WANDER:
			pass
		SHOOT:
			pass

func idle_state(delta):
	if player_detection.canSeePlayer():
		var angle_vector = player_detection.player.global_position - global_position
		
		rotate_barrel(angle_vector, delta)
		
		shoot(2)
