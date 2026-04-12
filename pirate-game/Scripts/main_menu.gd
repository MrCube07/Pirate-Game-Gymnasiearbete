extends MarginContainer

@export var main_menu_screen: MarginContainer
@export var level_menu_screen: MarginContainer

"""
MAIN MENU & LEVEL MANEGER
"""

#för knappar mellan menyer
func toggle_vis(objekt):
	if objekt.visible:
		objekt.visible = false
	else:
		objekt.visible = true
		
		


func _on_enter_level_menu_button_pressed() -> void:
	toggle_vis(main_menu_screen)
	toggle_vis(level_menu_screen)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")


func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")


func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")


func _on_level_4_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_4.tscn")
