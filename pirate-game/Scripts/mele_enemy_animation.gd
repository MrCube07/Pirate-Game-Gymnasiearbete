extends Node2D

@export var animation_tree: AnimationTree
@onready var enemy = get_owner()
@onready var cd: Timer = $Cd
var sword: bool = true
var attacking: bool = false
var idle: bool = true
var attack_attempt: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true
	animation_tree.set("parameters/Idle/blend_position", 1)
	animation_tree.set("parameters/SwordIdle/blend_position", 1)
	animation_tree.set("parameters/SwordSwing/blend_position", 1)
	animation_tree.set("parameters/SwordWalking/blend_position", 1)
	animation_tree.set("parameters/SpearIdle/blend_position", 1)
	animation_tree.set("parameters/SpearThrust/blend_position", 1)
	animation_tree.set("parameters/SpearWalking/blend_position", 1)
	animation_tree.set("parameters/AxeIdle/blend_position", 1)
	animation_tree.set("parameters/AxeSwing/blend_position", 1)
	animation_tree.set("parameters/AxeWalking/blend_position", 1)
	animation_tree.set("parameters/Walking/blend_position", 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	if idle and attacking == false:
		attacking = true
		cd.start()
	if enemy.velocity.length() > 150:
		idle = false
	else:
		idle = true
	




func _on_cd_timeout() -> void:
	attacking = false
	attack_attempt = false


func _on_attack_detection_body_entered(body: Node2D) -> void:
	attack_attempt = true
