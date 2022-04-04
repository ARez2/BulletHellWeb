extends KinematicBody2D
class_name Bullet

export (float, 0.95, 1, 0.0001) var damping : float = 1# 0.98
export var damage := 10
export var DelOnDmg := true
export var NumBounces := 1
export var MaxLifetime := 20
onready var bounces_left = NumBounces
export var Scale := 0.7
export var dir := Vector2()
export var speed := 5.0
export var SinusSpeed = false

var frame = 0

var time_since_bounce := 0.0

func _ready() -> void:
	if $Sprite.scale != Vector2(Scale, Scale):
		$Sprite.scale = Vector2(Scale, Scale)
		var colshape = CircleShape2D.new()
		colshape.radius = 4 - ((0.7 - Scale) * 10)
		$CollisionShape.shape = colshape
	$DieAfter.wait_time = MaxLifetime
	$DieAfter.start()


func _physics_process(delta: float) -> void:
	time_since_bounce += delta
	var s = 1
	if SinusSpeed:
		s = range_lerp(sin(time_since_bounce * 10), -1, 1, 0.2, 1)
	speed = speed * damping
	var velocity = dir * (s * speed)
	
	move_and_slide(velocity, Vector2.UP, true)

	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if collision != null and bounces_left > 0 and time_since_bounce > 0.1:
				dir = dir.bounce(collision.normal)
				bounces_left -= 1
				time_since_bounce = 0.0
			elif bounces_left == 0:
				die()
	


func _on_VisibilityNotifier_screen_exited() -> void:
	die()


func die() -> void:
	self.queue_free()


func _on_Area_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.take_damage(damage)
		if DelOnDmg:
			die()



func _on_PlayerDetector_body_entered(body: Node) -> void:
	if body is Player:
		die()
