extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var palettes = {
	preload("res://Assets/Tileset/original.png"): {
		"clear_color": Color(0.09, 0.11, 0.16, 1),
	},
	preload("res://Assets/Tileset/deep_maze.png"): {
		"clear_color": Color(0, 0.11, 0.16, 1),
	},
	preload("res://Assets/Tileset/eulbink.png"): {
		"clear_color": Color(0.13, 0.08, 0.2, 1),
	},
	preload("res://Assets/Tileset/MidnightAblaze.png"): {
		"clear_color": Color(0.02, 0.05, 0.02, 1),
	},
	preload("res://Assets/Tileset/SLS08.png"): {
		"clear_color": Color(0.05, 0.17, 0.27, 1),
	},
	preload("res://Assets/Tileset/ST8Greenery.png"): {
		"clear_color": Color(0.04, 0.11, 0.04, 1),
	},
}
var palette_swap_mat = preload("res://palette_swap.material")
onready var current_palette = palettes.keys()[0] setget set_current_palette

var detail_color = Color.white


func _ready() -> void:
	rng.randomize()
	set_random_palette()


func set_random_palette():
	var key = palettes.keys()[rng.randi_range(0, palettes.keys().size() - 1)]
	set_current_palette(key)


func set_current_palette(new : StreamTexture):
	current_palette = new
	palette_swap_mat.set_shader_param("palette", new)
	VisualServer.set_default_clear_color(palettes.get(new).clear_color)
	var img := new.get_data()
	img.lock()
	detail_color = img.get_pixel(320, 437)
	img.unlock()
