shader_type canvas_item;

uniform vec3 flash_color : source_color = vec3( 1.0,1.0,1.0 );
uniform float flash_modifier : hint_range(0.0,1.0) = 0.8;
uniform float outer_time = 0.0;
uniform float last_flash_time = -10.0;
uniform float flash_length = 0.1;

float intensity_from_time(float time_since_last_flash) {
	// Clamped lerp => [0.0, 1.0]
	float intensity = max(0.0, flash_length - time_since_last_flash) / flash_length;
	// Transition function
	//intensity = sqrt(intensity);
	return intensity * flash_modifier;
}

void fragment() {
		float time_since_last_flash = outer_time - last_flash_time;
		float intensity = intensity_from_time(time_since_last_flash);
		vec4 color = texture(TEXTURE, UV);
		color.rgb = mix(color.rgb, flash_color.rgb, intensity);
		COLOR = color;
}
