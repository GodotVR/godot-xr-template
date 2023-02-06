shader_type spatial;

uniform vec4 color : hint_color;
uniform vec2 wave = vec2(0.05, 0.05);
uniform vec2 speed = vec2(0.1, 0.2);

void vertex() {
	VERTEX.x = VERTEX.x + wave.x * sin(MODELVIEW_MATRIX[3][0] + speed.x * TIME) * abs(VERTEX.y);
	VERTEX.z = VERTEX.z + wave.y * sin(MODELVIEW_MATRIX[3][2] + speed.y * TIME) * abs(VERTEX.y);
}

void fragment() {
	ALBEDO = color.rgb;
}