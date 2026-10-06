@tool
extends Control

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6, Color.BLACK)
	draw_circle(Vector2.ZERO, 4, Color.LIGHT_SEA_GREEN)
	draw_circle(Vector2.ZERO, 2, Color.WHITE)

func set_active(active):
	if active:
		show()
	else:
		hide()
