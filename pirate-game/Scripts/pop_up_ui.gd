extends Control

signal health_changed

@onready var scoreLabel: Label = $popUp/baseMenuScreenContainer/baseMenuScreen/HBoxContainer/NinePatchRect/MarginContainer/statsScreen/scoreLabel
@export var player : Player
@export var swordPatchRect: NinePatchRect
@export var spearPatchRect: NinePatchRect
@export var axePatchRect: NinePatchRect
@export var healPatchRect: NinePatchRect
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scoreLabel.text = "SCORE: " + str(Global.score)

""" -------------------------SHOP-------------------------- """
func _on_sword_button_pressed() -> void:
	if Global.coins >= 150:
		Global.weapon = "Sword"
		Global.coins -= 150


func _on_spear_button_pressed() -> void:
	if Global.coins >= 250:
		Global.weapon = "Spear"
		Global.coins -= 250


func _on_axe_button_pressed() -> void:
	if Global.coins >= 400:
		Global.weapon = "Axe"
		Global.coins -= 400


func _on_heal_button_pressed() -> void:
	if Global.coins >= 100:
		player.stats.health += player.stats.base_max_health * 0.25
		Global.coins -= 100
		emit_signal("health_changed", player.stats.health)
