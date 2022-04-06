extends TileMap
class_name DestructibleTilemap

export var HP = 1000
var damage_status = {}

var parts := preload("res://Scenes/Utils/TilemapDestroyParticles.tscn")


func init() -> void:
	for c in get_used_cells():
		damage_status[global_position + map_to_world(c)] = HP


func damage_cell(c_pos : Vector2, dmg : float):
	var to_world = map_to_world(c_pos)
	if damage_status.get(to_world) != null:
		damage_status[to_world] = damage_status[to_world] - dmg
		if damage_status[to_world] <= 0:
			destroy_cell(c_pos)


func destroy_cell(c_pos : Vector2):
	var p = parts.instance()
	p.get_node("Timer").connect("timeout", p, "queue_free")
	add_child(p)
	var to_world = map_to_world(c_pos)
	p.global_position = to_world
	p.restart()
	set_cell(c_pos.x - world_to_map(global_position).x, c_pos.y - world_to_map(global_position).y, -1)
	damage_status.erase(map_to_world(c_pos))
