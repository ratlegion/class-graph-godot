@tool
extends Control

@export var camera: Control

var dragging: bool = false

var zoom_speed = 1.25

var zoom = 1

func _ready() -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if dragging:
			camera.position += event.relative
	
	if event is InputEventMouseButton:
		if event.button_index == 1:
			dragging = event.pressed
		elif event.button_index == 4:
			zoom_screen(zoom_speed, event.global_position)
		elif event.button_index == 5:
			zoom_screen(-zoom_speed, event.global_position)

func zoom_screen(amount, mouse_pos):
	var old_zoom = zoom
	
	if amount >= 0:
		zoom *= amount
	else:
		zoom /= amount
	
	camera.scale = Vector2(zoom,zoom)
	
	camera.global_position -= (mouse_pos - camera.global_position) * ((zoom / old_zoom) - 1)
