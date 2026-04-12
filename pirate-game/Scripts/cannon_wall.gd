extends CharacterBody2D
class_name CannonWall



enum{IDLE, ATTACKING, CD, BROKEN}

var state = IDLE
var cooldown: bool = true
var can_die: bool = false

@export var stats: Stats
@onready var main = get_tree().current_scene
@onready var cannon_ball = load("res://Scenes/cannon_ball.tscn")
@onready var sight: RayCast2D = $RayCast2D
@onready var cd: Timer = $CD_timer
@onready var startup: Timer = $Startup

func _ready() -> void:
	if stats:
		stats.initialize()
	startup.start()
##################### GENERAL HELP FUNKTIONS ###################
func shoot():
	var instance = cannon_ball.instantiate()
	# Vi hämtar den globala rotationen från Muzzle-noden
	var rot = $Muzzle.global_rotation
	
	instance.spawnPos = $Muzzle.global_position
	instance.spawnRot = rot
	
	instance.dir = Vector2.UP.rotated(rot) 
	

	main.call_deferred("add_child", instance)
	
	

###################### GAME LOOP ###############################
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		ATTACKING:
			_attacking_state(delta)
		BROKEN:
			_broken_state(delta)
			
			
###################### STATE FUNKTIONS #########################

func _idle_state(delta):
	if sight.is_colliding() and cooldown == true:
		_enter_attacking_state()
	
	if stats.health <= 0 and can_die:
		_enter_broken_state()
func _attacking_state(delta):
	_idle_state(delta)
	
func _broken_state(delta):
	set_physics_process(false)
	Global.score += 50
	
##################### ENTER STATE FUNKTIONS #####################

func _enter_idle_state():
	state = IDLE

func _enter_attacking_state():
	state = ATTACKING
	shoot()
	cd.start()
	cooldown = false

func _enter_broken_state():
	state = BROKEN
	
##################### SAIGNALS #################################

func _on_cd_timer_timeout() -> void:
	cooldown = true


func _on_startup_timeout() -> void:
	can_die = true
