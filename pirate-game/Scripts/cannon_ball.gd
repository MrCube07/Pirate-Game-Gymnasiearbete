extends Area2D

# Referens till Stats om du vill att kulan ska ha en "ägare" (valfritt)
@export var stats: Stats
@export var BALL_SPEED = 600 

@onready var Sprite: Sprite2D = $Sprite2D
# Antar att du använder AnimatedSprite2D för explosionerna eftersom du kallar på .play()
@onready var explosions = [$Explosion, $Explosion2, $Explosion3, $Explosion4, $Explosion5]

# NYTT: Vi hämtar våra Hitbox-barn. 
# ImpactHitbox sköter skadan när kulan träffar ett skepp.
# ExplosionHitbox sköter skadan när den sprängs.
@onready var impact_hitbox: Hitbox = $impact_hitbox
@onready var explosion_hitbox: Hitbox = $ExplosionRadius

var dir: Vector2 = Vector2.ZERO
var spawnPos: Vector2
var spawnRot: float
var stop: bool = false
var exploded: bool = false

func _ready() -> void:
	global_position = spawnPos
	global_rotation = spawnRot
	
	# Göm alla visuella explosioner vid start
	for exp in explosions:
		exp.visible = false
	
	# SETUP FÖR EXPLOSION HITBOX (Ska vara avstängd tills vi sprängs)
	if explosion_hitbox:
		explosion_hitbox.monitoring = false # Scannar inte
		explosion_hitbox.monitorable = false
		explosion_hitbox.is_explosion = true # Viktigt för resistens-uträkningen!
		# Sätt skada om du inte satt det i editorn


	# SETUP FÖR IMPACT HITBOX (Ska vara igång direkt)
	if impact_hitbox:
		impact_hitbox.monitoring = true # Scannar efter hurtboxes
		impact_hitbox.monitorable = false
			
		


func _physics_process(delta):
	if not stop and dir != Vector2.ZERO:
		# Vi rör oss nu i vektorns riktning multiplicerat med hastighet och tid
		global_position += dir * BALL_SPEED * delta

func explode():
	if exploded: return
	exploded = true
	stop = true
	
	# 1. Stäng av ImpactHitbox så vi inte råkar träffa igen mitt i explosionen
	if impact_hitbox:
		impact_hitbox.set_deferred("monitoring", false)
	
	# 2. Aktivera ExplosionHitbox så den skadar allt i närheten
	if explosion_hitbox:
		# Vi använder set_deferred för att undvika fysikfel mitt i en frame
		explosion_hitbox.set_deferred("monitoring", true)
	
	# 3. Visuell hantering (ditt gamla system)
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
