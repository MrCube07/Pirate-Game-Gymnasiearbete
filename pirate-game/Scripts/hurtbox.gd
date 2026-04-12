class_name Hurtbox extends Area2D


@onready var owner_stats: Stats = owner.stats

#frö health_bar
signal health_changed



func _ready() -> void:
	monitoring = false

func recieve_hit(hitbox: Hitbox) -> void:# hitbox definieras här
	if not owner_stats:
		return
		   
	var incoming_damage: float = float(hitbox.get_damage())
	var final_damage: float = 0.0
	# damage calc för explosions/ vanliga attacker
	if hitbox.is_explosion:
		final_damage = incoming_damage * (1.0 - owner_stats.explosion_resistance)
	else:
		
		final_damage = max(incoming_damage - owner_stats.current_defence, 1.0)
	
	owner_stats.health -= int(final_damage)
	health_changed.emit(owner_stats.health) 
	
	#print(owner.name, " HP: ", owner_stats.health, " (Tog ", int(final_damage), " skada)")
