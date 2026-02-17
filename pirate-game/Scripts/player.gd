extends CharacterBody2D

class_name Player

const MAX_SPEED:int = 250
const ACC:int = 50
const FRIC:int = 5

enum { IDLE, WALK, ATTACKING, DEAD }

var state = IDLE
var is_attacking: bool = false
var is_dead: bool = false


@export var stats: Stats
@onready var camera: Camera2D = $Camera2D
@onready var player_animations: AnimationPlayer = $player_animations
@onready var animation_tree: AnimationTree = $AnimationTree



func _ready() -> void:
	stats.initialize()
	

######################### GAME LOOP #############################
func _physics_process(delta: float) -> void:
	
	look_at(get_global_mouse_position())
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			_dead_state(delta)
			

#################### GENERAL FUNKTIONS #############################

func _movement(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("Move_Right") - Input.get_action_strength("Move_Left"),
		Input.get_action_strength("Move_Down") - Input.get_action_strength("Move_Up")
	).normalized()
		
	var lerp_weigth = delta * (ACC if input else FRIC)
	velocity = lerp(velocity, input * MAX_SPEED, lerp_weigth)
	
	move_and_slide()
	
	

#################### STATE FUNKTIONS ###############################

func _idle_state(delta):
	_movement(delta)
	if velocity.length() > 0:
		_enter_walk_state()
func _walk_state(delta):
	_movement(delta)
	if velocity.length() == 0:
		_enter_idle_state()
func _dead_state(delta):
	pass
	

#################### ENTER STATE FUNKTIONS ##########################
func _enter_idle_state():
	state = IDLE

func _enter_walk_state():
	state = WALK

func _enter_dead_state():
	pass
