extends Node2D

@export var animation_tree: AnimationTree
@onready var player: Player = get_owner()
@onready var cd: Timer = $Cd
var sword: bool = false
var spear: bool = false
var axe: bool = false
var attacking = false
var idle = true
#akrivera animationer
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

func _process(delta: float) -> void:
	#Conditions för animation tree
	if Global.weapon == "Sword":
		sword = true
		player.sword.visible = true
		return
		
	else:
		sword = false
		player.sword.visible = false
		
	if Global.weapon == "Spear":
		spear = true
		player.spear.visible = true
		return
		
	else:
		spear = false
		player.spear.visible = false
		
	if Global.weapon == "Axe":
		axe = true
		player.axe.visible = true
		return
		
	else:
		axe = false
		player.axe.visible = false


func _physics_process(delta: float) -> void:
# Conditions för animation tree
	if Input.is_action_just_pressed("Use_Weapon") and attacking == false:
		attacking = true
		#cooldown
		cd.start()
	if player.velocity.length() > 150:
		idle = false
	else:
		idle = true
		
	

	



func _on_cd_timeout() -> void:
	#cooldown reset
	attacking = false
