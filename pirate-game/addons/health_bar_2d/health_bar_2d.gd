extends TextureProgressBar

# if false, health bar will only show itself when value is changed
@export var _static:bool = false
# if set true, health bar color will change as value decreases
@export var _gradient:bool = false
# time out for show/hide health bar animation
@export var _animation_timeout:float = 1.0
# offset of health bar from player
@export var _offset:Vector2 = Vector2(0, -6)

# Colors #
const _colors = {
	"neutral": "#00489d",
	"danger": "#9d0000",
	"success": "#009d36",
	"caution": "#d1ce00"
}

var _parent: Node
var _center_offset: Vector2 = size/2
#var _tween: Tween
@onready var _timer: Timer = Timer.new()


func _ready() -> void:
	
	add_child(_timer)
	_timer.timeout.connect(_fade)
	_timer.wait_time = _animation_timeout
	_timer.one_shot = true # Ensure it doesn't loop
	
	_setup()


func _setup() -> void:
	# We don't need to create the timer here anymore
	if not _static:
		# We only connect the visibility logic if not static
		if not is_connected("value_changed", _show):
			value_changed.connect(_show)
		modulate.a = 0
		
	if _gradient:
		if not is_connected("value_changed", _color):
			value_changed.connect(_color)


func _process(_delta) -> void:
	if _parent:
		# Control nodes use 'rotation'. We subtract the parent's rotation 
		# to keep the bar visually upright (horizontal).
		rotation = -_parent.rotation
		
		# Use global_position to place it relative to the world, not the rotating parent
		global_position = _parent.global_position + _offset - _center_offset


func setup_with_stats(stats_resource: Stats) -> void:
	_parent = get_parent()
	max_value = stats_resource.current_max_health
	value = stats_resource.health
	
	# Connect directly to the Stats resource signal
	# This avoids all the issues with Enemy/Hurtbox signal typos
	stats_resource.health_changed.connect(_on_stats_health_changed)
	
	print("HealthBar: Connected directly to Stats Resource")

func _on_stats_health_changed(current: int, _max_hp: int) -> void:
	value = current
	# If you want the color to update or the bar to show up on hit:
	_show(current) 
	if _gradient:
		_color(current)

func _handle_value(val: int) -> void:
	"""Sets the parent health to texture progress value.
	"""
	if max_value >= val:
		value = val


func _show(val: float) -> void:
	"""Method handles the health bar visibility.
	"""
	if _timer:
		_timer.start()
		_tween(1)


func _fade() -> void:
	"""Method handles the health bar visibility.
	"""
	_tween(0)


func _color(val: float) -> void:
	"""Method handles the color of health bar.
	"""
	if _prc(val, 30):
		tint_progress = _colors.danger
	elif _prc(val, 55):
		tint_progress = _colors.caution
	else:
		tint_progress = _colors.success


func _prc(val: float, percentage: int) -> bool:
	"""Method returns true if health bar is in certain percentage."""
	return val <= max_value*(percentage/100.0)


func _tween(target_opacity: float) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	# Use target_opacity instead of 'value' to avoid confusion with progress value
	tween.tween_property(self, "modulate:a", target_opacity, _animation_timeout)
