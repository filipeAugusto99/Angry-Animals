extends TextureButton

func _ready() -> void:
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	scale = Vector2(1.1, 1.1)
  
func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
