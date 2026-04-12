extends CharacterBody2D

class_name Player

signal player_health_changed
signal low_hp
signal hp_restore

const MAX_SPEED:int = 250
const ACC:int = 50
const FRIC:int = 5

enum { IDLE, WALK, ATTACKING}

var state = IDLE
var is_attacking: bool = false
var can_die: bool = false
var on_board: bool = false
var low_hp_variable = false


@export var stats: Stats
@export var pop_up:Control
@onready var camera: Camera2D = $Camera2D
@onready var player_animations: AnimationPlayer = $player_animations
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var startup: Timer = $startup
@onready var health_bar = $UI/HUD/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/NinePatchRect/HealthBar2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var sword: Polygon2D = $Polygons/Sword
@onready var spear: Polygon2D = $Polygons/Spear
@onready var axe: Polygon2D = $Polygons/Axe


##################### MAIN LOOP #########################
func _ready():
	#print(stats.current_damage)
	await get_tree().process_frame
	if stats:
		stats.initialize()
		health_bar.setup_with_stats(stats)
	startup.start()
	"""krävs för att stats ska kunna ladda in, 
	utan det dör alla enemies/spelaren för att hp kollas innan stats har laddat in"""
	var starthp = stats.base_max_health
	#print(starthp)
	
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
	#ganska simpel movementfuntion om man jämför med andra komponenter
	

#################### STATE FUNKTIONS ###############################

func _idle_state(delta):
	_movement(delta)
	if velocity.length() > 0:
		_enter_walk_state()

	if stats.health <= 0 and can_die:
		#död
		get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")
		
func _walk_state(delta):
	_movement(delta)
	if velocity.length() == 0:
		_enter_idle_state()
	if stats.health <= 0 and can_die:
		get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")



#################### ENTER STATE FUNKTIONS ##########################
func _enter_idle_state():
	state = IDLE

func _enter_walk_state():
	state = WALK




func _on_startup_timeout() -> void:
	can_die = true


func _on_hurtbox_health_changed(new_health: int) -> void:
	# healthbar
	emit_signal("player_health_changed", new_health)
	#musik, byter mysik vid 30% hp
	if stats.health < 300 and not low_hp_variable:
		emit_signal("low_hp")
		low_hp_variable = true
	elif stats.health > 300 and low_hp_variable:
		emit_signal("hp_restore")
		low_hp_variable = false
