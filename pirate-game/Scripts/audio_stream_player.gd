extends AudioStreamPlayer

@onready var music: AudioStreamPlaybackInteractive = self.get_stream_playback()


"""    
Musik :)
"""

func _on_player_low_hp() -> void:
	music.switch_to_clip_by_name(&"lowhp")


func _on_player_hp_restore() -> void:
	music.switch_to_clip_by_name(&"default")
