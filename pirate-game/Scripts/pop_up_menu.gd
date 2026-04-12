extends MarginContainer

@export var menu_screen: VBoxContainer
@export var open_menu_screen: VBoxContainer
@export var help_menu_screen: VBoxContainer
@export var settings_menu_screeen: VBoxContainer
@export var quit_menu_screen: MarginContainer
@export var shop_menu_screen: MarginContainer
#visibility toggle mellan de olika menyerna
func toggle_vis(objekt):
	if objekt.visible:
		objekt.visible = false
	else:
		objekt.visible = true

func _on_menu_button_pressed() -> void:
	toggle_vis(menu_screen)
	toggle_vis(open_menu_screen)


func _on_toggle_help_button_pressed() -> void:
	toggle_vis(menu_screen)
	toggle_vis(help_menu_screen)


func _on_settings_toggle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/secret_hiddden_scene.tscn")


func _on_quit_button_pressed() -> void:
	toggle_vis(menu_screen)
	toggle_vis(quit_menu_screen)




func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/defeat_screen.tscn")


func _on_shop_button_pressed() -> void:
	toggle_vis(menu_screen)
	toggle_vis(shop_menu_screen)
