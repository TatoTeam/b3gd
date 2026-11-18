extends OptionButton


@export var class_script: Script

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		if not ResourceLoader.exists(global_class.path):
			continue
		
		var loaded_class := load(global_class.path)
		if loaded_class != null && does_script_extend_class(loaded_class, class_script):
			if global_class.is_abstract == true:
				continue
			
			if global_class.get("icon", "") != "":
				add_icon_item(load(global_class.icon), global_class.class)
			else:
				add_item(global_class.class)
			
			class_paths.append(global_class.path)
	
	selected = -1

func does_script_extend_class(base_script: Script, p_class_script: Script) -> bool:
	var current: Script = base_script
	
	while current != null:
		if current.get_path() == p_class_script.get_path():
			return true
		
		current = current.get_base_script()
	
	return false

func get_script_icon(script: Script) -> Texture2D:
	for entry in ProjectSettings.get_global_class_list():
		if entry["path"] == script.resource_path:
			var icon_path: String = entry["icon"]
			if not icon_path.is_empty():
				return load(icon_path) as Texture2D
			
			break
	
	return null
