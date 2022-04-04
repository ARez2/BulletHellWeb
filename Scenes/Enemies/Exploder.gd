extends KinematicBody2D

export var Speed := 20
export var ExplosionDamage := 30
export var ExplodeDist := 20
export var TimeBeforeExplosion := 1
var exploding = false
var player = null

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if !exploding:
		var velocity = global_position.direction_to(player.global_position)
		velocity *= Speed
		move_and_slide(velocity)
	
	if global_position.distance_to(player.global_position) < ExplodeDist:
		explode()
		

func explode() -> void:
	exploding = true
	yield(get_tree().create_timer(TimeBeforeExplosion), "timeout")
	if !is_instance_valid(self):
		return
	var p = $CPUParticles2D
	remove_child(p)
	yield(get_tree(), "physics_frame")
	for body in $PlayerDetect.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(ExplosionDamage)
	ObjectManager.add_particles(p, global_position)
	queue_free()


func _on_PlayerDetect_body_entered(body: Node) -> void:
	$Radius.modulate = Color.red
	$Radius.modulate.a = 0.3
	$TriggeredSprite.show()
	$CalmSprite.hide()
	
	player = body
