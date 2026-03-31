extends Control
@export var player: Player
@onready var scoreLabel: Label = $popUp/baseMenuScreenContainer/baseMenuScreen/HBoxContainer/NinePatchRect/MarginContainer/statsScreen/scoreLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scoreLabel.text = "SCORE: " + str(player.score)
