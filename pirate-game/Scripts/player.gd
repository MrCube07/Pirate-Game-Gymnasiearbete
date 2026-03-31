extends CharacterBody2D

class_name Player

signal player_health_changed

const MAX_SPEED:int = 250
const ACC:int = 50
const FRIC:int = 5

enum { IDLE, WALK, ATTACKING}

var state = IDLE
var is_attacking: bool = false
var can_die: bool = false

var coins: int = 0
var score: int = 0

@export var stats: Stats
@onready var camera: Camera2D = $Camera2D
@onready var player_animations: AnimationPlayer = $player_animations
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var startup: Timer = $startup
@onready var health_bar = $UI/HUD/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/NinePatchRect/HealthBar2D
@onready var hurtbox: Area2D = $Hurtbox


##################### MAIN LOOP #########################
func _ready():
	await get_tree().process_frame
	if stats:
		stats.initialize()
		# Pass the actual stats resource to the bar
		health_bar.setup_with_stats(stats)
	startup.start()
	
func _physics_process(delta: float) -> void:
	
	look_at(get_global_mouse_position())
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
			

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
	if stats.health <= 0 and can_die:
		get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")
		print("player")
func _walk_state(delta):
	_movement(delta)
	if velocity.length() == 0:
		_enter_idle_state()
	if stats.health <= 0 and can_die:
		get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")
		print("player")


#################### ENTER STATE FUNKTIONS ##########################
func _enter_idle_state():
	state = IDLE

func _enter_walk_state():
	state = WALK




func _on_startup_timeout() -> void:
	can_die = true


func _on_hurtbox_health_changed(new_health: int) -> void:
		# Now we pass that value along to the health bar via our local signal
	emit_signal("player_health_changed", new_health)
