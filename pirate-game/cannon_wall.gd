extends CharacterBody2D
class_name CannonWall

const PROJECTILE_SPEED: int = 25

enum{IDLE, ATTACKING, CD, BROKEN}

var state = IDLE
var hp:int = 3

@onready var sight: RayCast2D = $RayCast2D



###################### GAME LOOP ###############################
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		ATTACKING:
			_attacking_state(delta)
		CD:
			_cd_state(delta)
		BROKEN:
			_broken_state(delta)
			
			
###################### STATE FUNKTIONS #########################

func _idle_state(delta):
	pass

func _attacking_state(delta):
	pass

func _cd_state(delta):
	pass

func _broken_state(delta):
	pass
	
	
##################### ENTER STATE FUNKTIONS #####################

func _enter_idle_state(delta):
	state = IDLE

func _enter_attacking_state(delta):
	state = ATTACKING

func  _enter_cd_state(delta):
	state = CD
