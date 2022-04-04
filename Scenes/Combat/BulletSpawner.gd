tool
extends Node2D

export var NumSpawnpoints := 3 setget set_spawnpoints
export var DistFromCenter := 1.0 setget set_dist
export var RotateSpeed := 0.0
export var SpawnFrequency := 0.4 setget set_frequency
export var BulletSpeed := 70
export var BulletSinusSpeed := false
export var BulletBounces := 0
export var BulletScale := 0.7
export (float, 0.99, 1, 0.0001) var BulletDamping : float = 1# 0.98
export var shoot = true

var BulletScene = preload("res://Scenes/Combat/Bullet.tscn")

signal shoot

func _process(delta: float) -> void:
	if RotateSpeed > 0:
		rotation += RotateSpeed * delta


func set_frequency(new):
	SpawnFrequency = new
	$SpawnAfter.wait_time = new


func set_dist(new):
	DistFromCenter = new
	set_spawnpoints(NumSpawnpoints)


func set_spawnpoints(new):
	NumSpawnpoints = new
	for c in self.get_children():
		if "SpawnPoint" in c.name:
			c.queue_free()
	
	var angle = 360 / new
	var current_angle = 0.0
	for i in range(new):
		var pt = Position2D.new()
		add_child(pt)
		pt.set_owner(self)
		pt.name = "SpawnPoint"
		pt.position = (Vector2.RIGHT * DistFromCenter).rotated(deg2rad(current_angle))
		pt.rotation = deg2rad(current_angle)
		pt.gizmo_extents = 5
		current_angle += angle


func spawn():
	if !is_processing() or !get_parent().is_processing() or !shoot:
		return
	emit_signal("shoot")
	for spt in self.get_children():
		if "SpawnPoint" in spt.name:
			var b = BulletScene.instance()
			b.rotation = rotation
			b.global_position = global_position
			b.NumBounces = BulletBounces
			b.Scale = BulletScale
			ObjectManager.add_bullet(b)
			#yield(get_tree(), "node_added")
			if !is_instance_valid(b):
				return
			b.dir = b.global_position.direction_to(spt.global_position)
			b.speed = BulletSpeed
			b.SinusSpeed = BulletSinusSpeed
			b.damping = BulletDamping
