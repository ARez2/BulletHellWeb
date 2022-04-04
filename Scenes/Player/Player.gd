extends KinematicBody2D
class_name Player

export var Sensitivity = 10 # 65 for 1:1 scale
export var MaxSpeed = 800
export var Gravity := 10

var pressed_down = false
var mouse_movement := Vector2()
var initial_pos := Vector2()

onready var camera : Camera2D = get_tree().get_nodes_in_group("cam")[0]
onready var camera_target = get_tree().get_nodes_in_group("cam_target")[0]
onready var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
onready var crosshair_outer = get_tree().get_nodes_in_group("crosshair")[0].get_child(0)
onready var crosshair_inner = get_tree().get_nodes_in_group("crosshair")[0].get_child(1)
var playersize = 8
var tilemap_size = 16

var velocity := Vector2()


func _input(event: InputEvent) -> void:
	var mousebutton = event as InputEventMouseButton
	if mousebutton:
		if mousebutton.button_index == 1:
			if !pressed_down and mousebutton.pressed:
				initial_pos = get_viewport().get_mouse_position()
			pressed_down = mousebutton.pressed
	var movement = event as InputEventMouseMotion
	if movement:
		mouse_movement = movement.relative * Sensitivity


# The higher the velocity, the more blocks it will affect


var last_side_hit = 0.0
func _physics_process(delta: float) -> void:
	last_side_hit += delta
	var v_len := 0.0
	if pressed_down:
		var mouse_pos = get_viewport().get_mouse_position()
		velocity = initial_pos.direction_to(mouse_pos)
		velocity *= (mouse_pos - initial_pos).length() * 4
		
		crosshair_inner.global_position = mouse_pos
		crosshair_outer.global_position = initial_pos
	else:
		velocity = velocity * 0.97
		velocity.y += Gravity
		mouse_movement = Vector2.ZERO
	v_len = velocity.length()
	
	crosshair_inner.visible = pressed_down
	crosshair_outer.visible = pressed_down

	velocity = move_and_slide(velocity + mouse_movement)# - mouse_movement
	
	var min_diff = 50
	if get_slide_count() > 0 \
		and v_len - velocity.length() > min_diff \
		and last_side_hit > 0.2 \
		and v_len > 100:
		last_side_hit = 0.0
		$Dust.look_at($Dust.global_position + get_slide_collision(0).normal)
		$Dust.restart()
		var tilemap = get_slide_collision(0).collider as TileMap
		if tilemap is DestructibleTilemap:
			var pos = tilemap.world_to_map(global_position)
			var smash_radius = (MaxSpeed / min_diff) - (MaxSpeed / v_len)
			smash_radius /= 5
			smash_radius = int(smash_radius)
			for x in range(-smash_radius, smash_radius):
				for y in range(-smash_radius, smash_radius):
					RoomsManager.damage_cell(pos + Vector2(x, y), v_len)
			get_tree().get_nodes_in_group("cam")[0].add_trauma(.2)
	
	if velocity != Vector2.ZERO:
		$Sprite.flip_h = velocity.x < 0
	
	mouse_movement = Vector2.ZERO


func take_damage(amt):
	print("Dmg: ", amt)


func _on_PressurePlate_trigger() -> void:
	Gravity = 0 if Gravity == 10 else 10
