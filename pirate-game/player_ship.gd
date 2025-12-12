extends CharacterBody2D


const MAX_SPEED:int = 250
const ACC:int = 50
const FRIC:int = 5

enum{ IDLE, DRIVING, SHOOTING, SUNKEN}

var state = IDLE
var is_sunken: bool = false


##################### MAIN LOOP #########################

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		DRIVING:
			_driving_state(delta)
		SHOOTING:
			_shooting_state(delta)
		SUNKEN:
			_sunken_state(delta)
			
################### GENERAL FUNKTIONS ####################

func _movement(delta: float) -> void:
	var dir = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")
	velocity = velocity.move_toward(dir*MAX_SPEED, ACC)
	
	
	
	move_and_slide()
	if velocity.length() > 0:
		rotation = velocity.angle()


################## STATE FUNKTIONS #######################

func _idle_state(delta):
	pass
	
func _driving_state(delta):
	pass

func _shooting_state(delta):
	pass

func _sunken_state(delta):
	pass


############## ENTER STATE FUNKTIONS ####################

func _enter_idle_state():
	pass

func _enter_driving_state():
	pass

func _enter_shooting_state():
	pass

func _enter_sunken_state():
	pass
