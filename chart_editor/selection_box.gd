extends NinePatchRect

@onready var timeline = $".."

var dragging: bool = false

var dragging_start: Vector2
var dragging_end: Vector2

func _ready():
	visible = false

func _process(_delta):
	if Input.is_action_just_pressed("fake_ui_mouse_down") && Input.is_key_pressed(KEY_SHIFT):
		dragging = true
		dragging_start = timeline.get_local_mouse_position()
	
	if dragging:
		visible = true
		dragging_end = timeline.get_local_mouse_position()
		
		var start := dragging_start
		var end := dragging_end
		
		if end.x < start.x:
			var old := start.x
			start.x = end.x
			end.x = old
		
		if end.y < start.y:
			var old := start.y
			start.y = end.y
			end.y = old
		
		position = start
		size = end - start
		
		if !Input.is_action_pressed("fake_ui_mouse_down") || !Input.is_key_pressed(KEY_SHIFT):
			dragging = false
			select_inside()

func select_inside():
	visible = false
	
	if size.x < 10 && size.y < 10:
		return
	
	var selectables: Array[TimelinePoint] = []
	
	for node: Control in get_tree().get_nodes_in_group(&"Selectable"):
		if get_global_rect().has_point(node.global_position):
			if node is EditorEvent:
				selectables.append(node.event)
			elif node is EditorNote:
				selectables.append(node.note)
			
	ChartEditor.add_new_selection(selectables)
