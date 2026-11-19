shader_type canvas_item;

void fragment() {
	COLOR.a = mod(FRAGCOORD.x + FRAGCOORD.y, 2.0);
}
