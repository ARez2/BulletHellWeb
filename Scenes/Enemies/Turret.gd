extends KinematicBody2D


onready var player : Player = get_tree().get_nodes_in_group("player")[0]

func _process(delta: float) -> void:
	$BulletSpawner.look_at(player.global_position)
	$Sprite.flip_h = player.global_position.x < global_position.x
	$Light.position.x = 2.5 * sign(global_position.x - player.global_position.x)


func _on_ShootSalvo_timeout() -> void:
	$BulletSpawner.shoot = !$BulletSpawner.shoot
	$Light.visible = $BulletSpawner.shoot
	if $BulletSpawner.shoot:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
