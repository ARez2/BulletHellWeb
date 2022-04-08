extends KinematicBody2D

export var Speed := 20

var direction := Vector2()
var velocity := Vector2()

var time_since_bounce = 0.0

func _ready() -> void:
	direction = Vector2(randf(), randf()).normalized()


func _physics_process(delta: float) -> void:
	time_since_bounce += delta
	$Sprite.flip_h = velocity.x < 0
	
	velocity = direction * Speed
	velocity = move_and_slide(velocity)
	
	for i in range(get_slide_count()):
		var col = get_slide_collision(i)
		if col != null and time_since_bounce > 0.1:
			direction = direction.bounce(col.normal)
			time_since_bounce = 0.0
		#velocity = direction
		#global_position += col.normal
		#velocity = direction * Speed


func _on_BulletSpawner_shoot() -> void:
	$SlimeSound2.play()


func _on_VisibilityEnabler2D_screen_entered() -> void:
	$SlimeSound1.play()


func _on_VisibilityEnabler2D_screen_exited() -> void:
	$SlimeSound1.stop()
