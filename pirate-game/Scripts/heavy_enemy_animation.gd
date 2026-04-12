extends Node2D

@export var animation_tree: AnimationTree
@onready var enemy = get_owner()
@onready var cd: Timer = $Cd
var axe: bool = true
var attacking: bool = false
var idle: bool = true
var attack_attempt: bool = false
# activera animationer för animation tree
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



func _physics_process(delta: float) -> void:
	#animationsligik
	if idle and attacking == false:
		attacking = true
		cd.start()
	if enemy.velocity.length() > 50:
		idle = false
	else:
		idle = true
	




func _on_cd_timeout() -> void:
	#animationslogik
	attacking = false
	attack_attempt = false


func _on_attack_detection_body_entered(body: Node2D) -> void:
	attack_attempt = true
