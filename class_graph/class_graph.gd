@tool
extends EditorPlugin

var dock

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree():
	dock = preload("./editor_dock.tscn").instantiate()
	add_dock(dock)

func _exit_tree():
	remove_dock(dock)
	dock.queue_free()
	dock = null
