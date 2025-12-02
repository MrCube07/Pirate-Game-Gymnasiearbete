extends Area2D



@export var BALL_SPEED = 10



@onready var Expl1: AnimatedSprite2D = $Explosion
@onready var Expl2: AnimatedSprite2D = $Explosion2
@onready var Expl3: AnimatedSprite2D = $Explosion3
@onready var Expl4: AnimatedSprite2D = $Explosion4
@onready var Expl5: AnimatedSprite2D = $Explosion5
@onready var Sprite: Sprite2D = $Sprite2D



var Anim = [Expl1, Expl2, Expl3, Expl4, Expl5]
var dir: float
var spawnPos: Vector2
var spawnRot: float
var stop: bool = false

var exploded = false

func _ready() -> void:
	global_position = spawnPos
	global_rotation = spawnRot
	randomize()
	





func _physics_process(delta):
	if not stop:
		position += Vector2.UP.rotated(dir) * BALL_SPEED
	else:
		pass
		
	
	
func explode():
	var anim_number = randi_range(1, 5)
	var exp: AnimatedSprite2D

	match anim_number:
		1: exp = Expl1
		2: exp = Expl2
		3: exp = Expl3
		4: exp = Expl4
		_: exp = Expl5

	# Gör explosionen synlig och gömmer kannonkulan
	exp.visible = true
	Sprite.visible = false
	# Spela animationen
	exp.frame = 0
	exp.play()

	# Vänta tills animationen är klar
	await exp.animation_finished
	
	
	# Radera hela kulan + explosionerna tillsammans
	queue_free()

	


###################### SIGNALS ############################





func _on_body_entered(body: Node2D) -> void:
	if not exploded:
		stop = true
		explode()
		exploded = true
