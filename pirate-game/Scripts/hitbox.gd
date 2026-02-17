class_name Hitbox extends Area2D

signal hit_registered

@export_group("Stats & Damage")
@export var attacker_stats: Stats 
@export var is_explosion: bool = false

func _ready() -> void:
	monitoring = true
	monitorable = false
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# 1. Kolla om det är en Hurtbox
	if not area.has_method("recieve_hit"):
		return
	
	# 2. FIXEN FÖR SJÄLVSKADA:
	# Om ägaren till Hurtboxen är samma som ägaren till Hitboxen -> Avbryt.
	# "owner" är oftast root-noden (CharacterBody2D)
	if area.owner == owner:
		return
	
	# 3. DEBUGGING (Kolla output-fönstret när du slår!)
	var dmg = get_damage()
	#print("Hitbox träffade ", area.owner.name, ". Skada som skickas: ", dmg)
	
	if dmg == 0:
		print("VARNING: Skadan är 0! Har du dragit in Stats-resursen i Hitboxens Inspector?")

	# Skicka träffen
	area.recieve_hit(self)
	hit_registered.emit()


func get_damage() -> int:
	return owner.stats.current_damage # Använd det beräknade värdet
