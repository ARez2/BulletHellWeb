extends KinematicBody2D
class_name Player

# ====================== VARIABLES ======================
# ----------- EXPORTS -----------
export var Sensitivity := 10 # 65 for 1:1 scale
export var MaxSpeed := 300
export var Gravity := 7
export var FloorSpeed := 4
export var FloorDeAccel := 13.0
export var AirSpeed := 1
export var AirDeAccel := 10
export var JumpPower := 400
export var MinJumpMouseMovement := 15

# ----------- NORMAL -----------
var pressed_down := false
var mouse_movement := Vector2()
var initial_pos := Vector2()
var horizontal_velocity := Vector2()
var vertical_velocity := Vector2()
var last_velocity := Vector2()
var playersize := 8
var tilemap_size := 16
var min_vel_diff := 25
var last_side_hit = 0.0
var prev_on_floor := false

# ----------- ONREADY -----------
onready var camera : Camera2D = get_tree().get_nodes_in_group("cam")[0]
onready var camera_target = get_tree().get_nodes_in_group("cam_target")[0]
onready var screen_size := Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
onready var crosshair_outer : Sprite = get_tree().get_nodes_in_group("crosshair")[0].get_child(0)
onready var crosshair_inner : Sprite = get_tree().get_nodes_in_group("crosshair")[0].get_child(1)
onready var floor_check : RayCast2D = $FloorCheck
onready var animplayer : AnimationPlayer = $AnimationPlayer



# ====================== MAIN FUNCTIONS ======================

func _ready() -> void:
	pass


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


func _physics_process(delta: float) -> void:
	animplayer.playback_speed = 1
	last_side_hit += delta
	var on_floor := floor_check.is_colliding()
	
	# ----------- VELOCITY CALC -----------
	var v_len := 0.0
	var mouse_pos = get_viewport().get_mouse_position()
	if pressed_down:
		var dir = initial_pos.direction_to(mouse_pos)
		var dist = initial_pos.distance_to(mouse_pos)
		var in_top_half = mouse_pos.y < initial_pos.y
		var can_jump = dir.angle_to(Vector2.RIGHT) >= deg2rad(20) or dir.angle_to(Vector2.LEFT) >= deg2rad(20)
		can_jump = can_jump and on_floor
		
		horizontal_velocity = dir
		if is_on_floor() or on_floor:
			horizontal_velocity *= dist * FloorSpeed
			vertical_velocity.y = 0
			
			if mouse_movement.y < -MinJumpMouseMovement and \
			can_jump and \
			in_top_half:
				jump()
		else:
			var grav_multi := 1.0
			var down_dist = clamp(dist, 0, 30)
			if !in_top_half and dist > 3:
				grav_multi = down_dist / 10
			vertical_velocity.y += Gravity * grav_multi
			horizontal_velocity *= initial_pos.distance_to(mouse_pos) * AirSpeed
			
	else:
		if is_on_floor() or on_floor:
			horizontal_velocity = horizontal_velocity.linear_interpolate(Vector2.ZERO, FloorDeAccel * delta)
			vertical_velocity.y = 0
		else:
			vertical_velocity.y += Gravity
			horizontal_velocity = horizontal_velocity.linear_interpolate(Vector2.ZERO, AirDeAccel * delta)
	vertical_velocity.x = 0
	horizontal_velocity.y = 0
	
	horizontal_velocity.x = clamp(horizontal_velocity.x, -MaxSpeed, MaxSpeed)
	vertical_velocity.y = clamp(vertical_velocity.y, -MaxSpeed, MaxSpeed)
	
	var velocity := horizontal_velocity + vertical_velocity
	v_len = velocity.length()
	
	# ----------- VISUAL STUFF -----------
	crosshair_inner.global_position = mouse_pos
	crosshair_outer.global_position = initial_pos
	crosshair_inner.visible = pressed_down
	crosshair_outer.visible = pressed_down
	
	if on_floor:
		if v_len > 2:
			animplayer.playback_speed = v_len / 50
			animplayer.play("run")
		else:
			animplayer.play("idle")
	elif !on_floor and vertical_velocity.y > 0:
		animplayer.play("fall")
	
	
	if horizontal_velocity != Vector2.ZERO:
		$Sprite.flip_h = horizontal_velocity.x < 0
	
	
	# ----------- MOVE -----------
	velocity = move_and_slide(velocity)
	
	# ----------- POST MOVE -----------
	if get_slide_count() > 0 \
	  and v_len - velocity.length() > min_vel_diff \
	  and last_side_hit > 0.2 \
	  and v_len > 100:
		smash(v_len)
	if on_floor and !prev_on_floor:
		$FootDust.restart()
	mouse_movement = Vector2.ZERO
	last_velocity = velocity
	prev_on_floor = on_floor



# ====================== FUNCTIONS ======================
func smash(v_len) -> void:
	$SmashSound.play()
	last_side_hit = 0.0
	$SmashParticles.look_at($SmashParticles.global_position + get_slide_collision(0).normal)
	$SmashParticles.restart()
	ObjectManager.create_freeze_time()
	vertical_velocity.y *= 0.5
	var tilemap = get_slide_collision(0).collider as TileMap
	if tilemap is DestructibleTilemap:
		var pos = tilemap.world_to_map(global_position)
		var smash_radius = (float(MaxSpeed) / min_vel_diff) - (float(MaxSpeed / v_len))
		smash_radius /= 5
		smash_radius = int(smash_radius)
		for x in range(-smash_radius, smash_radius):
			for y in range(-smash_radius, smash_radius):
				RoomsManager.damage_cell(pos + Vector2(x, y), v_len)
		camera.add_trauma(.2)


func jump():
	animplayer.play("jump")
	vertical_velocity.y = -JumpPower


func take_damage(amt) -> void:
	animplayer.play("get_hit")
	$HurtParticles.restart()
