class_name Hitbox extends Area2D

signal hit_registered

var weapon_multiplyer: float = 1

@export_group("Stats & Damage")
@export var attacker_stats: Stats 
@export var is_explosion: bool = false

func _ready() -> void:
	monitoring = true
	monitorable = false
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)



func _on_area_entered(area: Area2D) -> void:
	# Kolla om det är en Hurtbox
	if not area.has_method("recieve_hit"):
		return
	
	
	# Om ägaren till Hurtboxen är samma som ägaren till Hitboxen -> Avbryt.
	# "owner" är oftast root-noden (CharacterBody2D)
	if area.owner == owner:
		return
	

	if owner is Player:
		_weapon_multiplyer_calc()
	else:
		weapon_multiplyer = 1

	var dmg = get_damage()
	#print("Hitbox träffade ", area.owner.name, ". Skada som skickas: ", dmg)
	#print(weapon_multiplyer)
	if dmg == 0:
		return

	# Skicka träffen
	area.recieve_hit(self)
	hit_registered.emit()


func get_damage() -> int:
	return owner.stats.current_damage * weapon_multiplyer # Använder det beräknade värdet


func _weapon_multiplyer_calc():
	#kunde inte fixa statsändringar vid vapenbyte så jag gjorde den här
	if Global.weapon == "Sword":
		weapon_multiplyer = 1.0
	elif Global.weapon == "Axe":
		weapon_multiplyer = 2.0
	elif Global.weapon == "Spear":
		weapon_multiplyer = 0.75
