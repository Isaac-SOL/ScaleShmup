
shader_type canvas_item;

uniform vec2 resolution = vec2(1920,1920);
uniform sampler2D noise_texture : filter_nearest, repeat_enable;
uniform float density = 30.0;
uniform vec2 speed_vec = vec2(0.0,0.0);
uniform float layers = 10.0;
uniform float alpha = 1.0;

void fragment(){
	vec2 uv = UV;
	uv.x *= resolution.x/resolution.y;
	float speed_x = speed_vec.x * 0.01;
	float speed_y = speed_vec.y * 0.01;
	vec2 speed = TIME * vec2(speed_x,speed_y)*0.1;
	float stars = 0.0;
	for(float f = 0.0; f < layers; f+=1.0){
		float shift = f * 0.2;
		float brightness = 1.0 - f *0.2;
		stars += step(0.2, pow(texture(noise_texture, uv + shift + speed * (1.0 - f *0.1)).r, density));
	}
		
	COLOR = vec4(vec3(stars),alpha); //+vec3(uv,0.0)
}










//shader_type canvas_item;
//
//uniform vec2 offset;
//uniform float alpha = 1.0;
//uniform float mult_size : hint_range( 0.01, 100 ) = 1.0;
//uniform float star_size = 1.0;
//
//
//#define M_PI 3.1415926535897932384626433832795
//
//float rand(vec2 co)
//{
    //return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
//}
//
//
//void fragment() {
	//float size = 30.0;
	//float prob = 0.95;
	//
	//vec2 uv = (UV * 2.0)-1.0;
	//vec2 uv0 = UV;
	////vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	//vec2 screen_size = vec2(1920,1920);
	//uv.x *= screen_size.x/screen_size.y ;
	//uv *= mult_size;
	//uv += offset;
	//uv = mod(uv + vec2(1, 1), 2) - vec2(1, 1);
	//
	//vec2 pos = floor(1.0 / size * FRAGCOORD.xy);
	////vec2 pos = uv;
	//
	//float color = 0.0;
	//float starValue = rand(pos);
	//
	//if (starValue > prob)
	//{
		//vec2 center = size * pos + vec2(size, size) * 0.5;
		//
		//float t = 0.9 + 0.2 * sin(TIME + (starValue - prob) / (1.0 - prob) * 45.0);
				//
		//color = star_size - distance(FRAGCOORD.xy, center) / (0.5 * size);
		//color = color * t / (abs(FRAGCOORD.y - uv.y)) * t / (abs(FRAGCOORD.x - uv.x));
	//}
	//else if (rand(FRAGCOORD.xy / screen_size.xy) > 0.996)
	//{
		//float r = 1.0/length(uv);
		//color = r * (0.25 * sin(TIME * (r * 5.0) + 720.0 * r) + 0.75);
	//}
	//
	//COLOR = vec4(vec3(color), 1.0);
//}
//
////void light() {
	//// Called for every pixel for every light affecting the CanvasItem.
	//// Uncomment to replace the default light processing function with this one.
////}
