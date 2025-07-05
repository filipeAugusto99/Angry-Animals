extends RigidBody2D

enum AnimalState { Ready, Drag, Release }

@onready var arrow: Sprite2D = $Arrow
@onready var debug_label: Label = $DebugLabel
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
@onready var kick_sound: AudioStreamPlayer2D = $KickSound
@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound

var _state: AnimalState = AnimalState.Ready
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _arrow_scale_x: float = 0.0

func _ready() -> void:
	setup()
	
func setup() -> void:
	_arrow_scale_x = arrow.scale.x
	arrow.hide()
	_start = position

func _physics_process(delta: float) -> void:
	update_debug_label()
	
func update_debug_label() -> void:
	var ds: String = "ST:%s SL:%s FR:%s\n" % [
		AnimalState.keys()[_state], sleeping ,freeze
	]
	
	ds += "_drag_start:%.1f, %.1f\n" % [_drag_start.x, _drag_start.y]
	ds += "_dragged_vector:%.1f, %.1f" % [_dragged_vector.x, _dragged_vector.y]
	debug_label.text = ds

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.

func _on_sleeping_state_changed() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node) -> void:
	pass # Replace with function body.
