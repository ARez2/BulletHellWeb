tool
extends Node2D
class_name PixelLight

export (float, 0, 100) var Size := 10.0 setget set_size
export (int, 0, 100) var Rings := 3 setget set_rings
export var Col : Color = Color(1, 0.31, 0.47, 0.5) setget set_color
export var Tex : Texture

export var NoiseScroll := 5
export var MinScale := Vector2(0.5, 0.5)
export var MaxScale := Vector2(5, 5)
export var NoiseTex : NoiseTexture setget set_noisetex

const DefaultTexture := preload("res://Assets/white_circle.png")

var sprite_scales = []
var offset = 0.0


func _ready() -> void:
	redraw()


func set_noisetex(new : NoiseTexture):
	NoiseTex = new
	if NoiseTex != null:
		NoiseTex.seamless = true
		NoiseTex.height = 1


func _process(delta: float) -> void:
	if $Sprites.get_child_count() > 0:
		offset += delta * NoiseScroll
		if NoiseTex != null and NoiseTex.noise != null:
			for i in range($Sprites.get_child_count()):
				var sprite = $Sprites.get_child(i)
				var noise_val = 0.0
				noise_val = NoiseTex.noise.get_noise_1d(i * sprite_scales.size() + offset)
				noise_val = range_lerp(noise_val, -1, 1, 0, 1)
				sprite.scale = sprite_scales[i] * Vector2(noise_val, noise_val)
				sprite.scale.x = clamp(sprite.scale.x, MinScale.x, MaxScale.x)
				sprite.scale.y = clamp(sprite.scale.y, MinScale.y, MaxScale.y)


func redraw():
	if !is_inside_tree() and !Engine.editor_hint:
		return
	sprite_scales.clear()
	for c in $Sprites.get_children():
		c.queue_free()
	var radius_step = float(Size) / float((Rings + 1))
	var curr_radius = radius_step
	for i in range(Rings):
		var r = Sprite.new()
		if Tex != null:
			r.texture = Tex
		else:
			r.texture = DefaultTexture
		r.scale = Vector2(curr_radius, curr_radius)
		sprite_scales.append(r.scale)
		r.modulate = Col
		r.z_index = i
		$Sprites.add_child(r)
		r.set_owner(self)
		curr_radius += radius_step


func set_size(new):
	Size = new
	if Engine.editor_hint:
		redraw()


func set_color(new):
	Col = new
	Col.a = 0.5
	if Engine.editor_hint:
		redraw()


func set_rings(new):
	Rings = new
	if Engine.editor_hint:
		redraw()
