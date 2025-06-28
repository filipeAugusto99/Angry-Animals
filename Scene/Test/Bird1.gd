extends RigidBody2D

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "FZ:%s CC:%d\nSL:%s" % [
		freeze, get_contact_count(),
		sleeping
	]


func _on_sleeping_state_changed() -> void:
	print("_on_sleeping_state_changed")


func _on_timer_timeout() -> void:
	freeze = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == 1:
			position = get_global_mouse_position()
