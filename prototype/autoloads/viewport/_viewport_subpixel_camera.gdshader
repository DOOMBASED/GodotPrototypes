// _viewport_subpixel_camera.gdshader
shader_type canvas_item;

uniform vec2 camera_offset = vec2(0.0, 0.0);

void vertex() {
	VERTEX += camera_offset;
}

void fragment() {}