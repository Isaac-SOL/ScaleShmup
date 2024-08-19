shader_type canvas_item;

uniform sampler2D text_img;
uniform float mult = 1.0;
uniform float offset;
uniform float time_mult = 0.5;
uniform float line_strenght = 0.5;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform	vec3 color_cell_a : source_color = vec3( 0.184, 0.055, 0.729 );
uniform	vec3 color_cell_b : source_color = vec3( 0, 0.282, 0.251);
uniform	vec3 param_cell_c : source_color = vec3( 0.804, 0.353,0.867);
uniform	vec3 param_cell_d : source_color = vec3( 0.377, 1.875,1.897);

vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d){
	return a + b * cos(6.28318*(c*t*d));
}

float noise3( vec3 x ) {
    vec3 p = floor(x),f = fract(x);

    f = f*f*(3.-2.*f);  // or smoothstep     // to make derivative continuous at borders

#define hash(p)  fract(sin(1e3*dot(p,vec3(1,57,-13.7)))*4375.5453)        // rand
    
    return mix( mix(mix( hash(p+vec3(0,0,0)), hash(p+vec3(1,0,0)),f.x),       // triilinear interp
                    mix( hash(p+vec3(0,1,0)), hash(p+vec3(1,1,0)),f.x),f.y),
                mix(mix( hash(p+vec3(0,0,1)), hash(p+vec3(1,0,1)),f.x),       
                    mix( hash(p+vec3(0,1,1)), hash(p+vec3(1,1,1)),f.x),f.y), f.z);
}

#define noise(x) (noise3(x)+noise3(x+11.5)) / 2.0 // pseudoperlin improvement from foxes idea 

void fragment() {
		vec2 uv = (SCREEN_UV * 2.0)-1.0;
		vec2 uv0 = UV;
		vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
		vec4 current_color;
		vec4 color;
		uv.x *= screen_size.x/screen_size.y ;
		uv *= mult;
		uv += offset;
		vec2 U = vec2(uv.x,uv.y);
	    vec2 R = screen_size.xy;
		
	for (float f = 0.0; f <=5.0; f++){
	    float n = noise(vec3(U*2.0/min(R.x,R.y), .03*TIME)),//first num controlls zoom, second speed.
	          v = sin(26.28*(sin(TIME / 25.0) + 4.)*n),
	        t = TIME;
	    
	    v = smoothstep(1.,0., .8*abs(v)/fwidth(v));
	    
		
		color = mix( exp(-50./R.y )* texture( text_img, (U+vec2(cos(0.3*TIME),sin(0.5*t)))/R), // .97
             .5+.5*sin(05.*n+(sin(TIME / 10.0) * 5.0)+vec4(0,2.1,-2.1,0)),
             v );
		current_color += textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	}
	
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
