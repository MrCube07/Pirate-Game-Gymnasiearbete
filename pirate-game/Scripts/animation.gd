extends Node2D

@export var animation_tree: AnimationTree
@onready var player: Player = get_owner()
@onready var weapon: String = "Sword"
@onready var cd: Timer = $Cd
var sword: bool = false
var attacking = false
var idle = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true

func _process(delta: float) -> void:
	if weapon == "Sword":
		sword = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("Use_Weapon") and attacking == false:
		attacking = true
		cd.start()
	if player.velocity.length() > 150:
		idle = false
	else:
		idle = true
		
	
	animation_tree.set("parameters/Idle/blend_position", 1)
	animation_tree.set("parameters/SwordIdle/blend_position", 1)
	animation_tree.set("parameters/SwordSwing/blend_position", 1)
	animation_tree.set("parameters/SwordWalking/blend_position", 1)
	animation_tree.set("parameters/Walking/blend_position", 1)
	



func _on_cd_timeout() -> void:
	attacking = false
