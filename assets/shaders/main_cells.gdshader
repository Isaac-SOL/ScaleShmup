shader_type canvas_item;

uniform vec2 offset;
uniform float alpha = 1.0;
uniform float mult_size = 1.0;
uniform float time_speed = 0.5;
uniform	vec3 color_cell_a : source_color = vec3(-0.002, 0.668, 0.448);
uniform	vec3 color_cell_b : source_color = vec3(0.078, 0.358, 0.380);
uniform	vec3 param_cell_c : source_color = vec3(-0.052, 0.388, 0.218);
uniform	vec3 param_cell_d : source_color = vec3(0.138, -2.422, -1.972);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform int pixel_size = 1;

vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d){
	return a + b * cos(6.28318*(c*t*d));
}

vec2 N22(vec2 p){
	vec3 a = fract(p.xyx * vec3(123.34, 234.34, 345.65));
	a+= dot(a,a+34.45);
	return fract(vec2(a.x *a.y, a.y *a.z));
}

// Called for every pixel the material is visible on.
void fragment() {
	float time = TIME * time_speed;
	vec2 uv = (SCREEN_UV * 2.0)-1.0;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	uv.x *= screen_size.x/screen_size.y ;
	uv *= mult_size;
	uv += offset;
	//uv = mod(uv + vec2(1, 1), 2) - vec2(1, 1);
	
	float min_dist = 100.0;
	vec2 grid_coords = floor(uv);
	vec2 grid_uv = fract(uv)-0.5;
	for (float y = -1.0; y<= 1.0; y++)
		for(float x = -1.0; x<= 1.0 ; x++){
			vec2 offset_cell =vec2(x,y);
			vec2 final_color = N22(offset_cell+ grid_coords);
			vec2 shift_neightboor = offset_cell+sin(final_color*time) * 0.5;
			float local_dist = length(grid_uv - shift_neightboor);
			if (local_dist < min_dist){
				min_dist = local_dist;
			}
	}
	vec3 color = vec3(palette(sqrt(min_dist),color_cell_a,color_cell_b,param_cell_c,param_cell_d));
	
	

	COLOR = vec4(color, alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
