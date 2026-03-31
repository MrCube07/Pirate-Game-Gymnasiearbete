extends MarginContainer

@export var main_menu_screen: MarginContainer
@export var level_menu_screen: MarginContainer




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
