extends ScrollContainer

@onready var right_bar_container = $RightBarContainer
const EVENT_INSPECT_PANEL = preload("uid://cvfmaitmtiau6")

var inspection_panels: Dictionary[Event, EventInspectPanel] = {}

func _ready():
	ChartEditor.instance.selection_updated.connect(func():
		for selectable_object in ChartEditor.instance.selection:
			if selectable_object is Event:
				var event: Event = selectable_object as Event
				if inspection_panels.keys().has(event): continue
				
				var inspect_panel: EventInspectPanel = EVENT_INSPECT_PANEL.instantiate()
				right_bar_container.add_child(inspect_panel)
				inspection_panels[event] = inspect_panel
				inspect_panel._load_event(event)
		
		for event in inspection_panels.keys().duplicate():
			if !ChartEditor.instance.selection.has(event):
				inspection_panels[event].queue_free()
				inspection_panels.erase(event)
	)
