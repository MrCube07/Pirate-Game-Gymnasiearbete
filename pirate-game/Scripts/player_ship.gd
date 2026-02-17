extends CharacterBody2D


const MAX_SPEED:int = 500
const ACC:int = 100
const FRIC:int = 50
const ROTATION_SPEED: float = 0.5

enum{ IDLE, DRIVING, SHOOTING, SUNKEN}

var state = IDLE
var is_sunken: bool = false
var player: Player = null

var normal_zoom = Vector2(1.0, 1.0) # Spelarens vanliga zoom
var boat_zoom = Vector2(0.5, 0.5)

var right_cooldown: bool = true
var left_cooldown: bool = true

var on_board = false

@export var stats: Stats
@onready var right_cd: Timer = $right_cannon_cd
@onready var left_cd: Timer = $left_cannon_cd
@onready var main = get_tree().current_scene
@onready var cannon_ball = load("res://Scenes/cannon_ball.tscn")
@onready var boat_camera: Camera2D = $Camera2D
@onready var driving_pos:Marker2D = $player_driving_pos
@onready var enter_area:Area2D = $EnterBoatArea


func _ready() -> void:
	if stats:
		stats.initialize()
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
func enter_boat(p: Player) -> void:
	if player != null: return
	
	player = p
	state = DRIVING

	# 1. Stäng av kollision och reparent
	player.get_node("CollisionShape2D").set_deferred("disabled", true)
	player.reparent(self) 
	
	# 2. Positionera på Marker2D
	player.position = driving_pos.position
	player.rotation = 0
	
	# 3. Kamerahantering
	boat_camera.make_current() # Växla till båtens kamera
	
	# Skapa en mjuk zoom-effekt (tar 0.8 sekunder)
	var tween = create_tween()
	tween.tween_property(boat_camera, "zoom", boat_zoom, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 4. Stäng av spelarens egen logik
	player.set_physics_process(false)
	player.set_process_input(false)
	player.visible = false # Dölj gubben när han är "i" båten om du vill
	
	enter_area.set_deferred("monitoring", false)
	on_board = true


func exit_boat() -> void:
	if player == null: return
	
	# 1. Återställ kameran till spelarens egna kamera
	# Vi antar att din Player-scen har en Camera2D
	var player_cam = player.get_node_or_null("Camera2D")
	if player_cam:
		player_cam.make_current()
		# Om du vill återställa zoomen på spelarens kamera direkt:
		player_cam.zoom = normal_zoom
	
	# 2. Flytta tillbaka spelaren till mappen (leveln)
	var level = get_parent()
	player.reparent(level)
	
	# 3. Aktivera spelaren igen
	player.get_node("CollisionShape2D").set_deferred("disabled", false)
	player.set_physics_process(true)
	player.set_process_input(true)
	player.visible = true
	
	# 4. Sätt spelaren precis bredvid båten
	player.global_position = global_position + Vector2(60, 0).rotated(rotation)
	
	player = null
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

################## STATE FUNKTIONS #######################

func _idle_state(delta):
	if on_board:
		# Kör rörelse (så du kan börja åka eller svänga även från idle)
		_movement(delta)
	
		# Om vi rör oss framåt, gå till DRIVING
		if Input.is_action_pressed("Move_Up"):
			state = DRIVING
	
		# Kolla efter skjut-input
		_check_shooting_input()

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
func _sunken_state(delta):
	pass


############## ENTER STATE FUNKTIONS ####################

func _enter_idle_state():
	state = IDLE

func _enter_driving_state():
	state = DRIVING

func _enter_shooting_state():
	state = SHOOTING

func _enter_sunken_state():
	pass

##################### ENTER AREAS ############################

func _on_enter_boat_area_body_entered(body: Node2D) -> void:
	# Om vi redan är i driving state eller någon redan är i båten: ignoreras
	if state == DRIVING or player != null:
		return
	# kontrollera att det verkligen är player
	if body is Player:
		enter_boat(body)
		
		
######################## TIMERS/COOLDOWNS ####################


func _on_right_cannon_cd_timeout() -> void:
	right_cooldown = true



func _on_left_cannon_cd_timeout() -> void:
	left_cooldown = true
