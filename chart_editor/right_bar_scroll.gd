extends ScrollContainer

@onready var right_bar_container = $RightBarContainer
const EVENT_INSPECT_PANEL = preload("uid://cvfmaitmtiau6")

var inspection_panels: Dictionary[TimelinePoint, InspectPanel] = {}

func _ready():
	ChartEditor.instance.selection_updated.connect(func():
		for selectable_object in ChartEditor.instance.selection:
			if inspection_panels.keys().has(selectable_object): 
				continue
			
			var inspect_panel: InspectPanel = EVENT_INSPECT_PANEL.instantiate()
			right_bar_container.add_child(inspect_panel)
			inspection_panels[selectable_object] = inspect_panel
			inspect_panel._load_event(selectable_object)
		
		for event in inspection_panels.keys().duplicate():
			if !ChartEditor.instance.selection.has(event):
				inspection_panels[event].queue_free()
				inspection_panels.erase(event)
	)
