extends Control

"""
HUD
"""

func _process(delta: float) -> void:
	$MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/coinsLabel.text = "COINS: " + str(Global.coins) 
