extends Resource
class_name Stats

"""
STATS

taget från youtube video, mycket användbar men hann inte använda buffs
https://www.youtube.com/watch?v=vsBb9921GfA&t=5s
"""


enum BuffableStats {
	MAX_HEALTH,
	DEFENCE,
	DAMAGE
}


const STAT_CURVES: Dictionary[BuffableStats, Curve] = {
	BuffableStats.MAX_HEALTH: preload("uid://cslswcsbctlxv"),
	BuffableStats.DEFENCE: preload("uid://dtet7kq8pfsnu"),
	BuffableStats.DAMAGE: preload("uid://cj0v216kw88pr")
}

const BASE_LEVEL_EXP: float = 100.0

signal health_depleted
signal health_changed(current_health: int, max_health: int)

@export_group("Base Stats")
@export var base_max_health: int = 100
@export var base_defence: int = 100
@export var base_damage: int = 100
@export var experience: int = 0: set = _on_experience_set
@export_range(0.0, 1.0) var explosion_resistance: float = 0.0

var level: int:
	get(): return floor(max(1.0, sqrt(experience / BASE_LEVEL_EXP) + 0.5))

var current_max_health: int = 100
var current_defence: int = 100
var current_damage: int = 100

var stat_buffs: Array[StatBuff]

var health: int = 0: set = _on_health_set



func initialize() -> void:
	recalculate_stats()
	health = current_max_health
	# Emit signal direkt så UI uppdateras vid start
	health_changed.emit(health, current_max_health)

func add_buffs(buff: StatBuff) -> void:
	stat_buffs.append(buff)
	recalculate_stats.call_deferred()

func remove_buffs(buff: StatBuff) -> void:
	stat_buffs.erase(buff)
	recalculate_stats.call_deferred()

func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {}
	var stat_addends: Dictionary = {}
	
	for buff in stat_buffs:
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
				
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] *= buff.buff_amount
				
				if stat_multipliers[stat_name] < 0.0:
					stat_multipliers[stat_name] = 0.0
	
	
	   
	var stat_sample_pos: float = (float(level) / 100.0) - 0.01
	"""
	if STAT_CURVES.has(BuffableStats.MAX_HEALTH):
		var multiplier = STAT_CURVES[BuffableStats.MAX_HEALTH].sample(stat_sample_pos)
		current_max_health = int(base_max_health * multiplier)
	else:
		"""
	current_max_health = base_max_health
	"""
	if STAT_CURVES.has(BuffableStats.DAMAGE):
		current_damage = int(base_damage * STAT_CURVES[BuffableStats.DAMAGE].sample(stat_sample_pos))
	else:
	"""
	current_damage = base_damage
	"""
	if STAT_CURVES.has(BuffableStats.DEFENCE):
		current_defence = int(base_defence * STAT_CURVES[BuffableStats.DEFENCE].sample(stat_sample_pos))
	else:"""
	
	current_defence = base_defence
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		if get(cur_property_name) != null:
			set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		if get(cur_property_name) != null:
			set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])

	# Uppdatera även health om max_hp ändrades
	health_changed.emit(health, current_max_health)

func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()

func _on_experience_set(new_value: int) -> void:
	var old_level: int = level
	experience = new_value
	
	if old_level != level:
		recalculate_stats()
