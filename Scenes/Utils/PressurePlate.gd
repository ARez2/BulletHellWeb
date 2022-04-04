extends Node2D

export var TimeToComplete := 5.0 setget set_completion_time
export var DecreaseSpeed := 2.5
export var OneShot := true
export var TriggerCD := 2.0

var progress = 0.0
var body_inside = false
var triggered = false
var time_since_trigger = 0.0

signal trigger


func set_completion_time(new):
	TimeToComplete = new


func _process(delta: float) -> void:
	time_since_trigger += delta
	
	if (OneShot and !triggered) or !OneShot:
		if body_inside:
			progress += delta
		else:
			progress -= DecreaseSpeed * delta
		progress = clamp(progress, 0, TimeToComplete)
		$TextureProgress.value = (progress / TimeToComplete) * 100
		if progress == TimeToComplete and time_since_trigger > TriggerCD:
			emit_signal("trigger")
			triggered = true
			time_since_trigger = 0.0
			$TextureProgress.tint_progress = Color.forestgreen
			$TextureProgress.tint_progress.a = 0.7
			$CPUParticles2D.restart()


func _on_Area2D_body_entered(body: Node) -> void:
	body_inside = true


func _on_Area2D_body_exited(body: Node) -> void:
	body_inside = false
	if !OneShot:
		$TextureProgress.tint_progress = Color.white
