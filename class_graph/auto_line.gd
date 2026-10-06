@tool
extends Line2D

@export var object_1: CanvasItem
@export var object_2: CanvasItem

var pos_1 := Vector2.ZERO
var pos_2 := Vector2.ZERO

func setup(o1: CanvasItem,o2: CanvasItem) -> void:
	object_1 = o1
	object_2 = o2
	
	object_1.item_rect_changed.connect(object_1_moved.bind(object_1))
	object_2.item_rect_changed.connect(object_2_moved.bind(object_2))
	
	if object_1.has_method("set_active"): object_1.set_active(true)
	if object_2.has_method("set_active"): object_2.set_active(true)

	pos_1 = object_1.global_position
	pos_2 = object_2.global_position
	
	update_line()

func object_1_moved(object):
	pos_1 = object.global_position

func object_2_moved(object):
	pos_2 = object.global_position

func update_line():
	global_position = Vector2.ZERO
	
	clear_points()
	
	add_point(pos_1)
	add_point(pos_2)
