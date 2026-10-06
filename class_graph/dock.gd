@tool
extends EditorDock

@export var viewport: Control
@export var items: Control
@export var item: PackedScene
@export var lines: Control
@export var line: PackedScene

var current_script

var class_tree = {}
var new_classes = {}

var class_list = []
var class_list_classes = {}

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_editor_resource_picker_resource_changed(resource: Resource) -> void:
	if resource is GDScript:
		current_script = resource
		$Vertical/MustBe.hide()
		load_tree(resource)
	else:
		$Vertical/MustBe.show()


func _on_resized() -> void:
	var top_left = $Vertical/ContentAlign.global_position
	var bottom_right = global_position + size
	
	viewport.size.x = bottom_right.x - top_left.x
	viewport.size.y = bottom_right.y - top_left.y

func search_classes(script: GDScript):
	var script_class = query_name(script)
	
	var remove_comments_regex = RegEx.create_from_string(r"#[^\n\r]*")
	
	var source_code = remove_comments_regex.sub(script.source_code, "", true)
	
	var regex = RegEx.create_from_string(r"[^\s,\.\:\;\(\)\[\]\{\}\*\+=\-<>\s%&|\\\n]+")
	
	var word_list = regex.search_all(source_code)
	
	
	for list_obj in word_list:
		var word = list_obj.get_string().strip_edges()
		
		if word != "" and class_list_classes.has(word):
			
			if word != script_class:
				if not class_tree.has(word):
					new_classes[word] = {}
					class_tree[word] = {
						"connections": [],
						"depth_min": class_tree[script_class].depth_min + 1,
						"depth_max": class_tree[script_class].depth_max + 1,
						"class_data": null,
					}
				
				else:
					class_tree[word].depth_min = min(
						class_tree[word].depth_min,
						class_tree[script_class].depth_min + 1
					)
					
					class_tree[word].depth_max = max(
						class_tree[word].depth_max,
						class_tree[script_class].depth_max + 1
					)
				
				#if not class_tree.has(script_class):
					#class_tree[script_class] = { "connections": [] }
				
				if not class_tree[script_class].connections.has(word):
					class_tree[script_class].connections.append(word)

func query_name(resource) -> String:
	
	var name = resource.get_global_name()
	
	if name == "" or name == null:
		name = resource.resource_path
	
	if name == "" or name == null:
		name = resource.get_instance_base_type()
	
	if name == "" or name == null:
		name = "Node"
	
	return str(name)

func get_class_data(class_id):
	if class_list_classes.has(class_id):
		return class_list_classes[class_id]
	else:
		var resource = ResourceLoader.load(class_id) as Script
		
		return {
			"path": class_id,
			"base": resource.get_instance_base_type(),
			"language": &"GDScript",
			"resource": resource
			}
		

func clear_tree():
	for child in items.get_children():
		child.queue_free()
	
	for child in lines.get_children():
		child.queue_free()
	
	new_classes = {}
	class_tree = {}

func load_tree(resource):
	clear_tree()
	
	class_list = ProjectSettings.get_global_class_list()
	
	class_list_classes = {}
	
	for class_item in class_list:
		class_list_classes[class_item.class] = {
			"path": class_item.path,
			"base": class_item.base,
			"icon": class_item.icon,
			"language": class_item.language,
			"resource": ResourceLoader.load(class_item.path)
		}
	
	
	var res_id = query_name(resource)
	
	class_tree = {
		res_id: {
			"connections":[],
			"depth_min": 0,
			"depth_max": 0,
			"class_data": get_class_data(res_id)
			}
		}
	
	search_classes(resource)
	
	while new_classes.keys().size() > 0:
		var class_key = new_classes.keys()[0]
		new_classes.erase(class_key)
		var set_class = get_class_data(class_key)
		
		
		if set_class.language != &"GDScript":
			continue
		
		var script = set_class.resource
		
		if script is not GDScript:
			continue
		
		class_tree[class_key].class_data = set_class
		
		search_classes(script)
	
	
	# This variable tracks each node aranged by its depth
	var items_per_depth: Array[Array] = []
	
	# add clases as nodes
	for class_item in class_tree:
		var item_data = class_tree[class_item]
		
		var new_item = item.instantiate()
		new_item.setup(class_item,item_data)
		
		if items_per_depth.size() <= item_data.depth_min:
			items_per_depth.resize(item_data.depth_min + 1)
		items_per_depth[item_data.depth_min].append(new_item)
		
		new_item.position = Vector2(
			0,
			item_data.depth_min * 100,
		)
		items.add_child(new_item)
		
		item_data.node = new_item
	
	for node_array in items_per_depth:
		if node_array == null: continue
		var node_width = 200
		var padding = 20
		for i in node_array.size():
			node_array[i].position.x = i * (node_width + padding) - \
			(node_array.size() * node_width + (node_array.size() -1) * padding) / 2
			
	
	# add lines between class_nodes
	for item_1 in class_tree:
		for item_2 in class_tree[item_1].connections:
			var new_line = line.instantiate()
			
			lines.add_child(new_line)
			
			new_line.setup(
				class_tree[item_1].node.line_out,
				class_tree[item_2].node.line_in
			)
