extends TextureButton


@export var level_number: String = "1"


@onready var level_label: Label = $MC/VB/LevelLabel


func _ready() -> void:
	level_label.text = level_number
	

func _on_mouse_entered() -> void:
	scale = Vector2(1.1, 1.1)

  
func _on_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)


func _on_pressed() -> void:
	ScoreManager.level_selected = level_number
	get_tree().change_scene_to_file(
		"res://Scene/LevelBase/Level%s.tscn" % level_number
	)
