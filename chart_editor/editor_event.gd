extends Control
class_name EditorEvent

const BUTTON_SIZE := Vector2(42.0, 36.0)
const LANE_WIDTH := 57.0

var event: Event

@onready var button: Button = $Button
@onready var arrow: NinePatchRect = $Arrow

func _ready() -> void:
	arrow.z_index = -1
	
	ChartEditor.instance.selection_updated.connect(func():
		button.set_pressed_no_signal(ChartEditor.selection.has(event))
	)

func update_visuals(icon: Texture2D) -> void:
	if button.icon != icon:
		button.icon = icon

	arrow.offset_right = 39.0 + event.lane * LANE_WIDTH

func _on_button_toggled(toggled_on):
	if toggled_on:
		if Input.is_key_pressed(KEY_SHIFT):
			ChartEditor.add_to_selection(event)
		else:
			ChartEditor.select_only(event)
	else:
		ChartEditor.remove_from_selection(event)

func _on_button_gui_input(input_event):
	if input_event is InputEventMouseButton:
		if input_event.pressed && input_event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			ChartEditor.instance.remove_event(event)
