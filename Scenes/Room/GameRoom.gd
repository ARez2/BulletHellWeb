extends Node2D
class_name GameRoom

var initialized = false

var active = false setget set_active
func set_active(new):
	active = new
	for node in self.get_children():
		if node is PixelLight:
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
		setactive_children(node)
var destructible_tilemap = null


func setactive_children(node):
	if node.get_child_count() <= 0:
		return
	for child in node.get_children():
		node.set_process(active)
		node.set_physics_process(active)
		setactive_children(child)


func _ready() -> void:
	for c in self.get_children():
		if c is DestructibleTilemap:
			destructible_tilemap = c
			break


func init():
	for c in self.get_children():
		if c is DestructibleTilemap:
			c.init()
	initialized = true


func room_enter():
	RoomsManager.generate_surrounding_rooms(self)
	RoomsManager.set_current_room(self)


func room_exit():
	pass



func _on_PlayerDetector_body_entered(body: Node) -> void:
	if body is Player:
		room_enter()
func _on_PlayerDetector_body_exited(body: Node) -> void:
	if body is Player:
		room_exit()



