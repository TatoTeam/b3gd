shader_type canvas_item;
instance uniform bool selected = false;

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	COLOR = texture(TEXTURE, UV) * modulate;
	if (selected) {
		COLOR = mix(vec4(1.0, 1.0, 1.0, COLOR.a), COLOR, 0.5 + (sin(TIME * 4.5) * 0.08));
	}
}
