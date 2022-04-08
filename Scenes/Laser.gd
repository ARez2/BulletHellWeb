extends Node2D

var enabled = false setget set_enabled
var t = 0.0
export var dmg = 10

onready var laser = $Laser
onready var ray = $RayCast2D

var target_width = 3


func _ready() -> void:
	laser.add_point(ray.position)
	#laser.add_point(ray.position + ray.cast_to)
	laser.add_point(ray.position)


func set_enabled(new):
	enabled = new
	laser.visible = enabled
	ray.enabled = enabled
	$Sound.playing = enabled


func _physics_process(delta: float) -> void:
	t += delta
	if enabled:
		laser.width = target_width * sin(30 * t) + target_width*2
		laser.width = clamp(laser.width, 0, 8)
		if ray.is_colliding():
			laser.set_point_position(1, to_local(ray.get_collision_point()))
		else:
			laser.set_point_position(1, ray.position + ray.cast_to)
		


func _on_Timer_timeout() -> void:
	if ray.is_colliding() and ray.get_collider() is Player:
		ray.get_collider().take_damage(dmg)
