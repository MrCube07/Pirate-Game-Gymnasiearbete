extends Control

@export var player: Player

func _process(delta: float) -> void:
	$MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/coinsLabel.text = "COINS: " + str(player.coins) 
