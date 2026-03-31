extends CharacterBody2D


const MAX_SPEED:int = 500
const ACC:int = 100
const FRIC:int = 50
const ROTATION_SPEED: float = 0.5

enum{ IDLE, DRIVING, SHOOTING}

var state = IDLE
var is_sunken: bool = false


var normal_zoom = Vector2(1.0, 1.0) # Spelarens vanliga zoom
var boat_zoom = Vector2(0.5, 0.5)

var right_cooldown: bool = true
var left_cooldown: bool = true

var on_board = false
var player_at_dock: CharacterBody2D = null
var can_die:bool = false

@export var player: Player
@export var boat_entry: CanvasLayer



@export var stats: Stats
@onready var right_cd: Timer = $right_cannon_cd
@onready var left_cd: Timer = $left_cannon_cd
@onready var main = get_tree().current_scene
@onready var cannon_ball = load("res://Scenes/cannon_ball.tscn")
@onready var boat_camera: Camera2D = $Camera2D
@onready var driving_pos:Marker2D = $player_driving_pos
@onready var enter_area:Area2D = $EnterBoatArea
@onready var exit_pos: Marker2D = $player_exit_pos
@onready var startup: Timer = $startup
##################### MAIN LOOP #########################
func _ready():
	stats.initialize()
	startup.start()

func _physics_process(delta: float) -> void:
	if can_die and stats.health <= 0 and on_board:
		get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")
	elif can_die and stats.health <= 0:
		set_physics_process(false)
		boat_entry.visible = false
		enter_area.monitoring = false
	
	match state:
		IDLE:
			_idle_state(delta)
		DRIVING:
			_driving_state(delta)
		SHOOTING:
			_shooting_state(delta)

################### GENERAL FUNKTIONS ####################

func _movement(delta: float) -> void:
	# 1. Rotation (A och D)
	var rotation_dir = Input.get_axis("Move_Left", "Move_Right")
	rotation += rotation_dir * ROTATION_SPEED * delta

	# 2. Räkna ut riktning baserat på VAR båten pekar just nu
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	
	# 3. Gas (W)
	if Input.is_action_pressed("Move_Up"):
		# Accelerera i båtens nuvarande riktning
		velocity = velocity.move_toward(forward_direction * MAX_SPEED, ACC * delta)
	else:
		# Friktion - sakta ner när man inte gasar
		velocity = velocity.move_toward(Vector2.ZERO, FRIC * delta)

	
	move_and_slide()

# Function to make the player a child of the ship and stop controlling them
func enter_boat() -> void:
	# Om vi redan kör, eller om ingen spelare är i närheten, gör inget
	if on_board or player_at_dock == null: return
	
	# Sätt den faktiska player-variabeln till den som stod vid båten
	player = player_at_dock
	state = DRIVING
	on_board = true

	# 1. Stäng av kollision
	player.get_node("CollisionShape2D").set_deferred("disabled", true)
	if player.has_node("Hurtbox"):
		player.get_node("Hurtbox").set_deferred("monitoring", false)
	
	# 2. Flytta in spelaren i båtens hierarki
	player.reparent(self)
	player.position = driving_pos.position
	player.rotation = 0
	player.velocity = Vector2.ZERO # Stoppa all rörelse
	
	# 3. Kamerahantering
	boat_camera.make_current()
	var tween = create_tween()
	tween.tween_property(boat_camera, "zoom", boat_zoom, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 4. Inaktivera spelar-logik
	player.set_physics_process(false)
	player.set_process_unhandled_input(false) # Bättre än set_process_input
	player.visible = false 
	
	enter_area.set_deferred("monitoring", false)

func exit_boat() -> void:
	if player == null: return
	

	player.reparent(get_parent())

	var player_cam = player.get_node("Camera2D")
	
	player_cam.make_current()

	player.get_node("CollisionShape2D").set_deferred("disabled", false)
	if player.has_node("Hurtbox"):
		player.get_node("Hurtbox").set_deferred("monitoring", true)
	
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.visible = true
	
	# 4. Placera spelaren utanför båten
	player.global_position = exit_pos.global_position
	
	on_board = false
	player = null # Nollställ efter vi har klivit ur
	state = IDLE
	enter_area.set_deferred("monitoring", true)
	
func _check_shooting_input():
	if (Input.is_action_just_pressed("Pick_Up_Item") and right_cooldown) or \
	   (Input.is_action_just_pressed("Drop_Item") and left_cooldown):
		state = SHOOTING
	
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
	
func toggle_vis(objekt):
	if objekt.visible:
		objekt.visible = false
	else:
		objekt.visible = true

################## STATE FUNKTIONS #######################

func _idle_state(delta):
	if on_board:
		boat_entry.visible = true
		# Kör rörelse (så du kan börja åka eller svänga även från idle)
		_movement(delta)
	
		# Om vi rör oss framåt, gå till DRIVING
		if Input.is_action_pressed("Move_Up"):
			state = DRIVING
		
		if velocity.length() < 10 and Input.is_action_just_pressed("Pick_Up_Item"):
			exit_boat()
	
		# Kolla efter skjut-input
		_check_shooting_input()
	if boat_entry.visible == true and Input.is_action_just_pressed("Pick_Up_Item"):
		enter_boat()
		


func _driving_state(delta):
	_movement(delta)
	
	# Om vi stannar helt, gå till IDLE
	if velocity.length() < 10 and not Input.is_action_pressed("Move_Up"):
		state = IDLE
		
	_check_shooting_input()
	


func _shooting_state(delta):
	# Vi tillåter rörelse även när man skjuter (valfritt, annars ta bort _movement här)
	_movement(delta)
	
	if Input.is_action_just_pressed("Pick_Up_Item") and right_cooldown:
		right_shoot()
		right_cooldown = false
		right_cd.start()
		state = DRIVING # Gå tillbaka efter skott
		
	if Input.is_action_just_pressed("Drop_Item") and left_cooldown:
		left_shoot()
		left_cooldown = false
		left_cd.start()
		state = DRIVING # Gå tillbaka efter skott



############## ENTER STATE FUNKTIONS ####################

func _enter_idle_state():
	state = IDLE

func _enter_driving_state():
	state = DRIVING

func _enter_shooting_state():
	state = SHOOTING


##################### ENTER AREAS ############################

func _on_enter_boat_area_body_entered(body: Node2D) -> void:
	if body is Player: # Kontrollera att det är spelaren
		player_at_dock = body
		boat_entry.visible = true
	
	
######################## TIMERS/COOLDOWNS ####################


func _on_right_cannon_cd_timeout() -> void:
	right_cooldown = true



func _on_left_cannon_cd_timeout() -> void:
	left_cooldown = true


func _on_enter_boat_area_body_exited(body: Node2D) -> void:
	if body == player_at_dock:
		player_at_dock = null
		boat_entry.visible = false
	


func _on_startup_timeout() -> void:
	can_die = true
