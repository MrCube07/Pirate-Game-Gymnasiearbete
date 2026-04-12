extends CharacterBody2D

signal enemy_health_changed

const MAX_SPEED:int = 200
const ACC:int = 50
const FRIC:int = 5

enum { IDLE, WALK, ATTACKING, DEAD }


var state = IDLE
var is_attacking: bool = false
var is_dead: bool = false
var combat_range: int = 75
var detection_range: int = 1000
var can_die: bool = false

@export var stats: Stats
@export var player: Node2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var startup: Timer = $Startup
@onready var health_bar = $HealthBar2D
@onready var hurtbox: Area2D = $Hurtbox


func _ready():
	await get_tree().process_frame
	if stats:
		stats.initialize()
		health_bar.setup_with_stats(stats)
	
	startup.start()
	makepath()
	
	
	

######################### GAME LOOP #############################
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		DEAD:
			_dead_state(delta)
			

#################### GENERAL FUNKTIONS #############################

func _movement(delta: float) -> void:
	

	# Hämta nästa punkt i stigen
	var next_pos = nav_agent.get_next_path_position()
	
	# Räkna ut riktningen till punkten (global)
	var direction = global_position.direction_to(next_pos)
	
	rotation = direction.angle()
	var target_angle = direction.angle()
	
	# Rörelse framåt baserat på nuvarande rotation
	
	# Logik för om vi ska gå eller stanna
		
	var lerp_weigth = delta * ACC
	velocity = lerp(velocity, direction * MAX_SPEED, lerp_weigth)
	
	move_and_slide()
	
	
func makepath() -> void:
	nav_agent.target_position = player.global_position
#################### STATE FUNKTIONS ###############################

func _idle_state(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	var lerp_weigth = delta * FRIC
	var direction = player.global_position
	#velocity = lerp(velocity, direction, lerp_weigth)
	
	#move_and_slide()
	
	if dist_to_player < detection_range and combat_range < dist_to_player and not player.on_board:
		_enter_walk_state()
		
func _walk_state(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	_movement(delta)
	if dist_to_player + 100 < combat_range:
		_enter_idle_state()
	elif player.on_board == true:
		_enter_idle_state()
	if stats.health <= 0 and can_die:
		_enter_dead_state()
		
	
func _dead_state(delta):
	Global.coins += 40
	Global.score += 100
	queue_free()
	

#################### ENTER STATE FUNKTIONS ##########################
func _enter_idle_state():
	state = IDLE

func _enter_walk_state():
	state = WALK


func _enter_dead_state():
	state = DEAD


func _on_navigation_cd_timeout() -> void:
	makepath()


func _on_startup_timeout() -> void:
	can_die = true


func _on_hurtbox_health_changed(new_health: int) -> void:
	# Now we pass that value along to the health bar via our local signal
	emit_signal("enemy_health_changed", new_health)
