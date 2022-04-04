extends Node

const MaxBullets = 300

func add_bullet(bullet) -> void:
	if get_node_or_null("Bullets") == null:
		var b = Node.new()
		b.name = "Bullets"
		add_child(b)
	if !bullet is Bullet or $Bullets.get_child_count() >= MaxBullets:
		print("Too many bullets (> " + str(MaxBullets) + ")")
		return
	
	$Bullets.add_child(bullet)


func add_particles(parts : CPUParticles2D, pos : Vector2) -> void:
	if get_node_or_null("Particles") == null:
		var b = Node.new()
		b.name = "Particles"
		add_child(b)
	
	var timer = Timer.new()
	parts.add_child(timer)
	timer.wait_time = parts.lifetime
	timer.connect("timeout", parts, "queue_free")
	$Particles.add_child(parts)
	parts.global_position = pos
	timer.start()
	parts.restart()
