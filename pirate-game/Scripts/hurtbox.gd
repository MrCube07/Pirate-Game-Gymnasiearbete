class_name Hurtbox extends Area2D

# Vi hämtar stats från ägaren (Spelaren/Fienden).
# Detta förutsätter att owner har en variabel som heter 'stats'.
@onready var owner_stats: Stats = owner.stats

signal health_changed

func _ready() -> void:
	monitoring = false

func recieve_hit(hitbox: Hitbox) -> void:
	if not owner_stats:
		return
		
	var incoming_damage: float = float(hitbox.get_damage())
	var final_damage: float = 0.0
	
	if hitbox.is_explosion:
		# Explosion: Använd resistance
		final_damage = incoming_damage * (1.0 - owner_stats.explosion_resistance)
	else:
		# Vanlig träff: Använd defence
		final_damage = max(incoming_damage - owner_stats.current_defence, 1.0)
	
	owner_stats.health -= int(final_damage)
	emit_signal("health_changed", owner_stats.health)
	
	#print(owner.name, " HP: ", owner_stats.health, " (Tog ", int(final_damage), " skada)")
