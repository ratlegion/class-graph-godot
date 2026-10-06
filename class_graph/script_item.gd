@tool
extends Control

@export var name_tag: Label
@export var line_in: Control
@export var line_out: Control
@export var icon: TextureRect
@export var anim_player: AnimationPlayer
var linked_script

func _ready() -> void:
	pass

func setup(name,data):
	name_tag.text = name
	linked_script = data.class_data.resource
	if data.class_data.has("icon") && data.class_data.icon != "":
		icon.texture.resource_path = data.class_data.icon
	else:
		icon.texture = EditorInterface.get_editor_theme().get_icon("Script", "EditorIcons")

func edit_script() -> void:
	EditorInterface.edit_script(linked_script)


func _on_button_pressed() -> void:
	edit_script()
	anim_player.play("click")
