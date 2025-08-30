extends Control


const MAIN = preload("res://Scene/Main/Main.tscn")


@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var level_space: Label = $MarginContainer/VBGamerOver/LevelSpace
@onready var timer: Timer = $Timer
@onready var attempts_label: Label = $MarginContainer/VBoxContainer/AttemptsLabel
@onready var music: AudioStreamPlayer = $Music
@onready var vb_gamer_over: VBoxContainer = $MarginContainer/VBGamerOver


var _attempts: int = -1
var can_press: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('Exit') == true:
		get_tree().change_scene_to_packed(MAIN)
	
	if can_press and event.is_action_pressed('press_space'):
		get_tree().change_scene_to_packed(MAIN)

func _ready() -> void:
	level_label.text = "Level %s" % ScoreManager.level_selected
	on_attempt_made()
	
	
func _enter_tree() -> void:
	SignalHub.on_attempt_made.connect(on_attempt_made)
	SignalHub.on_cup_destroyed.connect(on_cup_destroyed)


func on_attempt_made() -> void:
	_attempts += 1
	attempts_label.text = "Attempts %s" % _attempts


func on_cup_destroyed(remaining_cups: int) -> void:
	if remaining_cups == 0:
		vb_gamer_over.show()
		music.play()
		timer.start()
		

func _on_timer_timeout() -> void:
	level_space.show()
	can_press = true
