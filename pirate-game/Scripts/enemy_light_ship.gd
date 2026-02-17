extends CharacterBody2D

const MAX_SPEED: int = 500
const ACC: int = 250
const FRIC: int = 250
const ROTATION_SPEED: float = 1

enum{ IDLE, DRIVING, SHOOTING, SUNKEN}

var state = DRIVING
var is_sunken: bool = false
var in_range = false

var right_cooldown: bool = true
var left_cooldown: bool = true
var cannon: String = ""

@export var stats: Stats
@export var combat_range: int = 1000
@export var detection_range: int = 4000.0
@export var player: Node2D
@onready var main = get_tree().current_scene
@onready var cannon_ball = load("res://Scenes/cannon_ball.tscn")
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var right_sight: RayCast2D = $right_cannon_range
@onready var left_sight: RayCast2D = $left_cannon_range
@onready var right_cd: Timer = $right_cd
@onready var left_cd: Timer = $left_cd

##################### MAIN LOOP #########################
func _ready():
	await get_tree().process_frame # Vänta på att nav-meshen laddas
	makepath()
	if stats:
		stats.initialize()

	
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

##################### GENERAL HELP FUNKTIONS ##############

func _movement(delta):

	# 1. Hämta nästa punkt i stigen
	var next_pos = nav_agent.get_next_path_position()
	
	# 2. Räkna ut riktningen till punkten (globalt)
	var direction = global_position.direction_to(next_pos)
	
	# 3. Rotera skeppet gradvis mot målet
	# lerp_angle ser till att skeppet roterar den kortaste vägen
	var target_angle = direction.angle()
	rotation = lerp_angle(rotation, target_angle, ROTATION_SPEED * delta)
	
	# 4. Rörelse framåt baserat på nuvarande rotation
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	
	# Logik för om vi ska åka eller stanna
	if not nav_agent.is_navigation_finished(): # Bättre än 'in_range' variabeln ibland
		velocity = velocity.move_toward(forward_direction * MAX_SPEED, ACC * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRIC * delta)
		
	move_and_slide()
	
func makepath() -> void:
	nav_agent.target_position = player.global_position

func right_shoot():
	var instance = cannon_ball.instantiate()
	var shoot_angle = global_rotation + PI
	
	instance.spawnPos = $right_muzzle.global_position
	instance.spawnRot = shoot_angle
	instance.dir = Vector2.UP.rotated(shoot_angle) # Skickar en riktningsvektor
	
	main.add_child.call_deferred(instance)

func left_shoot():
	var instance = cannon_ball.instantiate()
	var shoot_angle = global_rotation 
	
	instance.spawnPos = $left_muzzle.global_position
	instance.spawnRot = shoot_angle
	instance.dir = Vector2.UP.rotated(shoot_angle)
	
	main.add_child.call_deferred(instance)

func _check_sights_and_shoot():
	if right_cooldown and right_sight.is_colliding():
		cannon = "Right"
		_enter_shooting_state()
	elif left_cooldown and left_sight.is_colliding():
		cannon = "Left"
		_enter_shooting_state()

################# STATE FUNCTIONS #######################

func _idle_state(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	
	# 1. Transition: If player moves outside combat range, start driving again
	if dist_to_player > combat_range:
		_enter_driving_state()
		return

	# 2. Rotation: Turn Broadside
	var dir_to_player = global_position.direction_to(player.global_position)
	var angle_to_player = dir_to_player.angle()
	
	# Determine if player is on our left or right side to choose the best broadside
	var ship_forward = Vector2.RIGHT.rotated(rotation)
	var side_checker = ship_forward.cross(dir_to_player)
	
	var target_angle: float
	if side_checker > 0:
		target_angle = angle_to_player - PI/2 # Turn right side to player
	else:
		target_angle = angle_to_player + PI/2 # Turn left side to player
	
	rotation = lerp_angle(rotation, target_angle, ROTATION_SPEED * delta)

	# 3. Shooting: Check if sights are hitting player
	_check_sights_and_shoot()
	
	# 4. Movement: Stop entirely
	velocity = velocity.move_toward(Vector2.ZERO, FRIC * delta)
	move_and_slide()


func _driving_state(delta):
	var dist_to_player = global_position.distance_to(player.global_position)
	
	_movement(delta)
	
	# 1. Transition: Stop and fight if within combat range
	if dist_to_player < combat_range:
		_enter_idle_state()
		return
	
	# 2. Transition: Stop if player is totally out of detection range (optional)
	if dist_to_player > detection_range:
		velocity = velocity.move_toward(Vector2.ZERO, FRIC * delta)


func _shooting_state(delta):
	# Keep slowing down while shooting
	velocity = velocity.move_toward(Vector2.ZERO, FRIC * delta)
	move_and_slide()
	
	if cannon == "Right":
		right_shoot()
		right_cd.start()
		right_cooldown = false
	elif cannon == "Left":
		left_shoot()
		left_cd.start()
		left_cooldown = false
		
	# Return to idle (broadside positioning) immediately after firing
	_enter_idle_state()

func _sunken_state(delta):
	pass
	
	
#################### ENTER STATE FUNKTIONS ##############
func _enter_idle_state():
	state = IDLE
	
	
func _enter_driving_state():
	state = DRIVING
	
	
func _enter_shooting_state():
	state = SHOOTING
	
	
func _enter_sunken_state():
	state = SUNKEN
	
	
func _on_pathfind_cd_timeout() -> void:
	makepath()


func _on_right_cd_timeout() -> void:
	right_cooldown = true


func _on_left_cd_timeout() -> void:
	left_cooldown = true
