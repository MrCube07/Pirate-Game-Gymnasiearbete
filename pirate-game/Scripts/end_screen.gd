extends Control

"""
END SCREEN
"""



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_return_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
