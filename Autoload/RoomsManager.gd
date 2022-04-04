extends Node

const RoomSize := Vector2(192, 320)
var Rooms := {
	5: preload("res://Scenes/Room/NormalRoom.tscn"),
	2: preload("res://Scenes/Room/Shop.tscn"),
}
var RoomsWeighted = []

var currently_generated = {}
var unloaded_rooms = {}
var current_room = null

func _ready() -> void:
	for r in Rooms:
		for i in range(r):
			RoomsWeighted.append(Rooms.get(r))
	
	for c in get_tree().get_nodes_in_group("world")[0].get_children():
		if c is GameRoom:
			c.init()
			currently_generated[c.global_position] = c
	current_room = currently_generated.values()[0]
	current_room.active = true


func generate_surrounding_rooms(old_room):
	if Rooms.empty():
		return
	var world = get_tree().get_nodes_in_group("world")[0]
	for x in range(-1, 2):
		for y in range(-1, 2):
			var new_pos = old_room.global_position + RoomSize * Vector2(x, y)
			if (x == 0 and y == 0) or new_pos in currently_generated:
				var room : GameRoom = currently_generated.get(new_pos)
				if room != null and !room.initialized:
					room.init()
				continue
			elif new_pos in unloaded_rooms:
				var r = unloaded_rooms.get(new_pos)
				currently_generated[new_pos] = r
				unloaded_rooms.erase(new_pos)
				yield (get_tree(), "physics_frame")
				world.add_child(r)
				continue
			var ind = int(rand_range(0, RoomsWeighted.size()))
			var new_room = RoomsWeighted[ind].instance()
			yield (get_tree(), "physics_frame")
			world.add_child(new_room)
			new_room.global_position = new_pos
			new_room.init()
			new_room.active = false
			currently_generated[new_room.global_position] = new_room


func set_current_room(room):
	var t = get_tree().get_nodes_in_group("cam_target")[0]
	var sub = current_room.global_position - room.global_position
	var pos = current_room.global_position + Vector2(sign(-sub.x) * RoomSize.x, sign(-sub.y) * RoomSize.y)
	t.global_position = pos
	current_room.active = false
	current_room = room
	current_room.active = true
	
	clear_up_old_rooms(current_room)


func clear_up_old_rooms(current_room):
	for r in currently_generated:
		#if !currently_generated.has(r) or !is_instance_valid(currently_generated.get(r)):
		#	continue
		if current_room.global_position.distance_to(r) > RoomSize.length() * 4:
			if is_instance_valid(currently_generated.get(r)) and currently_generated.get(r) != null:
				currently_generated.get(r).queue_free()
			currently_generated.erase(r)
			continue
		if current_room.global_position.distance_to(r) > RoomSize.length() * 2:
			var room = currently_generated.get(r)
			unloaded_rooms[r] = room
			if is_instance_valid(room) and room.is_inside_tree():
				room.get_parent().remove_child(room)
			currently_generated.erase(r)
	
	for r in unloaded_rooms:
		if current_room.global_position.distance_to(r) > RoomSize.length() * 4:
			unloaded_rooms[r].queue_free()
			unloaded_rooms.erase(r)



func damage_cell(c_pos, dmg):
	for r in currently_generated:
		if !currently_generated.has(r) or !is_instance_valid(currently_generated.get(r)):
			continue
		var tilemap = currently_generated.get(r).destructible_tilemap
		if tilemap != null and tilemap is DestructibleTilemap:
			tilemap.damage_cell(c_pos, dmg)
			

func destroy_cell(c_pos):
	for r in currently_generated:
		if !currently_generated.has(r):
			continue
		for c in currently_generated.get(r).get_children():
			var tilemap = c as TileMap
			if tilemap:
				tilemap.set_cell(c_pos.x, c_pos.y, -1)


func _on_AutoClean_timeout() -> void:
	var t = Thread.new()
	t.start(self, "clear_up_old_rooms", current_room)
	t.wait_to_finish()
