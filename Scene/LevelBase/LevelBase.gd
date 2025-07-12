extends Node2D

const ANIMAL = preload("res://Scene/Animal/Animal.tscn")

@onready var animal_start: Marker2D = $AnimalStart

func _ready() -> void:
	spawn_animal()
	
func _enter_tree() -> void:
	SignalHub.on_animal_died.connect(spawn_animal)

func spawn_animal() -> void:
	var animal = ANIMAL.instantiate()
	animal.position = animal_start.position
	add_child(animal)


	
