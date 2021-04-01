extends Node2D


func _ready():
	InputMap.action_set_deadzone("ls_left", 0.05)
	InputMap.action_set_deadzone("ls_right", 0.05)
	InputMap.action_set_deadzone("ls_up", 0.05)
	InputMap.action_set_deadzone("ls_down", 0.05)

	InputMap.action_set_deadzone("rs_left", 0.05)
	InputMap.action_set_deadzone("rs_right", 0.05)
	InputMap.action_set_deadzone("rs_up", 0.05)
	InputMap.action_set_deadzone("rs_down", 0.05)
