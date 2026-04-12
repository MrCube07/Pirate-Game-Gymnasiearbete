extends Area2D


@export var stats: Stats
@export var BALL_SPEED = 600 

@onready var Sprite: Sprite2D = $Sprite2D
#Olika inställningar för olika animationer krävde olika AnimatedSprite2D
@onready var explosions = [$Explosion, $Explosion2, $Explosion3, $Explosion4, $Explosion5]


@onready var impact_hitbox: Hitbox = $impact_hitbox
@onready var explosion_hitbox: Hitbox = $ExplosionRadius

var dir: Vector2 = Vector2.ZERO
var spawnPos: Vector2
var spawnRot: float
var stop: bool = false
var exploded: bool = false

func _ready() -> void:
	#Definieras i parent
	global_position = spawnPos
	global_rotation = spawnRot
	
	# Göm alla visuella explosioner vid start
	for exp in explosions:
		exp.visible = false
	
	# explosion hitbox
	if explosion_hitbox:
		explosion_hitbox.monitoring = false # slutar skanna
		explosion_hitbox.monitorable = false
		explosion_hitbox.is_explosion = true # explosion resistans
		


	#impact hitbox
	if impact_hitbox:
		impact_hitbox.monitoring = true 
		impact_hitbox.monitorable = false
			
		


func _physics_process(delta):
	if not stop and dir != Vector2.ZERO:
		global_position += dir * BALL_SPEED * delta

func explode():
	#kommer bara köras en gång
	if exploded: return
	exploded = true
	# måste stanna för att inte animationen ska åka vidare
	stop = true
	
	# 1. Stäng av ImpactHitbox så vi träffar igen
	if impact_hitbox:
		impact_hitbox.set_deferred("monitoring", false)
	
	# 2. Aktivera ExplosionHitbox så den skadar allt i närheten
	if explosion_hitbox:
		explosion_hitbox.set_deferred("monitoring", true)
	
	
	var exp = explosions.pick_random() 
	exp.visible = true
	Sprite.visible = false
	exp.play()

	# Vänta tills animationen är klar
	await exp.animation_finished
	queue_free()

###################### SIGNALS ############################

	


func _on_body_entered(_body: Node2D) -> void:
	explode()
