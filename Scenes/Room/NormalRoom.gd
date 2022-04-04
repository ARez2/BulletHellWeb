extends GameRoom

export var Hazards = true

var lasers = []
const LaserScene = preload("res://Scenes/Laser.tscn")


func init():
	if Hazards:
		var r = $TileMap.get_used_rect()
		var tilesize = $TileMap.cell_size.x
		for x in range(1, r.size.x - 2):
			var ra = randf()
			if ra > 0.9:
				var l = LaserScene.instance()
				$Lasers.add_child(l)
				l.global_position = global_position + $TileMap.map_to_world(Vector2(x, r.position.y + 1))
				l.global_position.x += tilesize
				lasers.append(l)
	.init()


func _on_ActivateRandomLaser_timeout() -> void:
	if !Hazards:
		return
	for l in lasers:
		l.enabled = false
	for i in range(rand_range(0, lasers.size() - 1)):
		lasers[rand_range(0, lasers.size() - 1)].enabled = true
