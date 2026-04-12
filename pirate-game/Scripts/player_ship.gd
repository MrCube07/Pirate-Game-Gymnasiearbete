extends CharacterBody2D

signal boat_health_changed

const MAX_SPEED: int = 500
const ACC: int = 100
const FRIC: int = 50
const ROTATION_SPEED: float = 0.5

enum { IDLE, DRIVING, SHOOTING }

var state = IDLE
var is_sunken: bool = false

var normal_zoom = Vector2(1.0, 1.0)
var boat_zoom = Vector2(0.5, 0.5)

var right_cooldown: bool = true
var left_cooldown: bool = true

var on_board = false
var player_at_dock: CharacterBody2D = null
var can_die: bool = false

@export var player: Player
@export var boat_entry: CanvasLayer 
@export var stats: Stats

@onready var right_cd: Timer = $right_cannon_cd
@onready var left_cd: Timer = $left_cannon_cd
@onready var main = get_tree().current_scene
@onready var cannon_ball = load("res://Scenes/cannon_ball.tscn")
@onready var boat_camera: Camera2D = $Camera2D
@onready var driving_pos: Marker2D = $player_driving_pos
@onready var enter_area: Area2D = $EnterBoatArea
@onready var exit_pos: Marker2D = $player_exit_pos
@onready var startup: Timer = $startup
@onready var health_bar = $boatUI/MarginContainer/NinePatchRect/HealthBar2D
@onready var land_collide: RayCast2D = $player_exit_pos/RayCast2D
@onready var enter_label: Label = $boatUI/MarginContainer/MarginContainer/enterLabel

##################### MAIN LOOP #########################

func _ready():
	stats.initialize()
	health_bar.setup_with_stats(stats)
	startup.start()
	boat_entry.visible = false
	enter_label.visible = false

func _physics_process(delta: float) -> void:
	# hanterar death logic
	if can_die and stats.health <= 0:
		if on_board:
			get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")
		else:
			set_physics_process(false)
			boat_entry.visible = false
			enter_area.monitoring = false
			return
	
	
	match state:
		IDLE:
			_idle_state(delta)
		DRIVING:
			_driving_state(delta)
		SHOOTING:
			_shooting_state(delta)

	# 
	# om man inte activt gasar med w byts acc till fric
	if not on_board or not Input.is_action_pressed("Move_Up"):
		velocity = velocity.move_toward(Vector2.ZERO, FRIC * delta)
	
	
	move_and_slide()

################### UI & INTERACTION LOGIC ####################

func _handle_exit_ui_logic():
	if not on_board: return
	#boat ui bara på när player on_board
	if velocity.length() < 10 and land_collide.is_colliding():
		enter_label.text = "[E] Exit Boat"
		enter_label.visible = true
		if Input.is_action_just_pressed("Pick_Up_Item"):
			exit_boat()
	else:
		enter_label.visible = false

"""
Ska vara helt ärlig, hade väldigt mycket problem med enter/exit_boat funktionerna och tog
hjälp av en del ai, jag förstår därför inte helt själv exakt hur de fungerar men jag 
ska försöka förklara så bra jag kan
"""

func enter_boat() -> void:
	#on_board är om player redan är ett barn till player_boat etc
	#player_on_dock är om player är i enter_boat area2Dn
	if on_board or player_at_dock == null: return
	
	player = player_at_dock#(_on_enter_area_entered)
	state = DRIVING
	on_board = true
	player.on_board = true
	#Slår av spelaren när man kör båten, dock inte hurtboxen, däremot ökas explosion_resitance
	player.get_node("CollisionShape2D").set_deferred("disabled", true)
	if player.has_node("Hurtbox"):
		player.get_node("Hurtbox").set_deferred("monitoring", false)
	player.reparent(self)
	player.position = driving_pos.position
	player.rotation = 0
	player.velocity = Vector2.ZERO 
	player.stats.explosion_resistance = 0.7
	
	#enter_boat ui slås av i båten
	enter_label.visible = false 
	#byt camera
	boat_camera.make_current()
	var tween = create_tween()
	tween.tween_property(boat_camera, "zoom", boat_zoom, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#måste slås av efter att Camera2D buts, annar blir det problem med vem som ska ha camera2D
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.visible = false 
	
	enter_area.set_deferred("monitoring", false)

func exit_boat() -> void:
	#kollar om spelare är on_board
	if player == null: return
	#ger player samma "status" som player_boat och är inte längre barn till player_ship
	player.reparent(get_parent())
	#byter tillbaka cameran
	var player_cam = player.get_node("Camera2D")
	player_cam.make_current()
	#slår på player egenskaper och sätter tillbaka explosion_resistance till 0
	player.get_node("CollisionShape2D").set_deferred("disabled", false)
	if player.has_node("Hurtbox"):
		player.get_node("Hurtbox").set_deferred("monitoring", true)
	
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.visible = true
	player.global_position = exit_pos.global_position
	player.stats.explosion_resistance = 0
	
	on_board = false
	player.on_board = false
	player = null 
	state = IDLE
	#ställer tillbaka för enter_boat()
	enter_area.set_deferred("monitoring", true)
	enter_label.text = "[E] Enter Boat"
	enter_label.visible = true

################### MOVEMENT & COMBAT ####################

func _movement(delta: float) -> void:
	# om ingen on_board ska inte player_boat göra nånting
	if not on_board: return

	# Rotation
	var rotation_dir = Input.get_axis("Move_Left", "Move_Right")
	rotation += rotation_dir * ROTATION_SPEED * delta

	# Forward Velocity
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	if Input.is_action_pressed("Move_Up"):
		velocity = velocity.move_toward(forward_direction * MAX_SPEED, ACC * delta)
	

func _check_shooting_input():
	if not on_board: return 
	if (Input.is_action_just_pressed("Pick_Up_Item") and right_cooldown) or \
	   (Input.is_action_just_pressed("Drop_Item") and left_cooldown):
		state = SHOOTING


func right_shoot():
	var instance = cannon_ball.instantiate()
	var shoot_angle = global_rotation + PI
	#skickas till cannon_ball
	instance.spawnPos = $right_muzzle.global_position
	instance.spawnRot = shoot_angle
	instance.dir = Vector2.UP.rotated(shoot_angle)
	main.add_child.call_deferred(instance)

func left_shoot():
	var instance = cannon_ball.instantiate()
	var shoot_angle = global_rotation 
	#skickas till canon_ball
	instance.spawnPos = $left_muzzle.global_position
	instance.spawnRot = shoot_angle
	instance.dir = Vector2.UP.rotated(shoot_angle)
	main.add_child.call_deferred(instance)
	
"""
Hittade en bug som gör att man måste trycka två ggr för att ship ska skjuta men jag tyckte att det var
mer av ett feature eftersom man alltid måste ladda en canon innan man skjuter så jag behöll den
"""

################## STATE FUNCTIONS #######################

func _idle_state(delta):
	if on_board:
		_movement(delta)
		_handle_exit_ui_logic()
		_check_shooting_input()
		if Input.is_action_pressed("Move_Up"):
			state = DRIVING
	else:
		if player_at_dock != null and Input.is_action_just_pressed("Pick_Up_Item"):
			enter_boat()

func _driving_state(delta):
	_movement(delta)
	_handle_exit_ui_logic()
	_check_shooting_input()

func _shooting_state(delta):
	_movement(delta)
	if Input.is_action_just_pressed("Pick_Up_Item") and right_cooldown:
		right_shoot()
		right_cooldown = false
		right_cd.start()
		state = DRIVING
	if Input.is_action_just_pressed("Drop_Item") and left_cooldown:
		left_shoot()
		left_cooldown = false
		left_cd.start()
		state = DRIVING

##################### SIGNALS & TIMERS ############################

func _on_enter_boat_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_at_dock = body
		boat_entry.visible = true
		#byter text via kod så slipper jag ha flera labels
		enter_label.text = "[E] Enter Boat"
		enter_label.visible = true

func _on_enter_boat_area_body_exited(body: Node2D) -> void:
	#går bara vidare om det är player som lämnade enter_boat_area
	if body == player_at_dock:
		player_at_dock = null
		if not on_board:
			boat_entry.visible = false
			enter_label.visible = false

func _on_right_cannon_cd_timeout() -> void:
	right_cooldown = true

func _on_left_cannon_cd_timeout() -> void:
	left_cooldown = true

func _on_startup_timeout() -> void:
	can_die = true

func _on_hurtbox_health_changed(new_health: int) -> void:
	#healthbar
	emit_signal("boat_health_changed", new_health)
