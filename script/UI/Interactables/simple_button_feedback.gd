extends Button
class_name SimpleFeedbackButton

@export_range(1, 20) var modulate_feedback_multiplier : int = 2

func _on_button_down() -> void:
	modulate.a /= modulate_feedback_multiplier


func _on_button_up() -> void:
	modulate.a *= modulate_feedback_multiplier
