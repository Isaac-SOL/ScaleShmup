shader_type canvas_item;

//precision highp float;

uniform float mult_size = 1.0;
uniform float offset;
uniform float time_mult = 0.5;
uniform	vec3 color_cell_a : source_color = vec3( 0, 0.749, 0.486 );
uniform	vec3 color_cell_b : source_color = vec3( 0.22, 0.039, 0.357);
uniform	vec3 param_cell_c : source_color = vec3( 0.0, 0.0,0.09);
uniform	vec3 param_cell_d : source_color = vec3( 96, 478,0);

vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d){
	return a + b * cos(6.28318*(c*t*d));
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(vec2(c,s),vec2(-s,c));
}

const float pi = acos(-1.0);
const float pi2 = pi*2.0;

vec2 pmod(vec2 p, float r) {
    float a = atan(p.x, p.y) + pi/r;
    float n = pi2 / r;
    a = floor(a/n)*n;
    return p*rot(-a);
}

float box( vec3 p, vec3 b ) {
    vec3 d = abs(p) - b;
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float ifsBox(vec3 p) {
    for (int i=0; i<3; i++) {
        p = abs(p) - 1.0;
        p.xy *= rot(TIME*0.3);
        p.xz *= rot(TIME*0.1);
    }
    p.xz *= rot(TIME*0.5);
    return box(p, vec3(0.4,0.8,0.3));
}

float map(vec3 p, vec3 cPos) {
    vec3 p1 = p;
    p1.x = mod(p1.x-5., 10.) - 5.;
    p1.y = mod(p1.y-5., 10.) - 5.;
    p1.z = mod(p1.z, 16.)-8.;
    p1.xy = pmod(p1.xy, 5.0);
    return ifsBox(p1);
}



void fragment() {
	
	vec2 uv = (SCREEN_UV * 2.0)-1.0;
	vec2 uv0 = UV;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	uv.x *= screen_size.x/screen_size.y ;
	uv *= mult_size;
	uv += offset;
	uv = mod(uv + vec2(1, 1), 2) - vec2(1, 1);
	vec4 fragCoord = FRAGCOORD;
	
	//vec2 p = (fragCoord.xy * 2.0 - screen_size.xy) / min(screen_size.x, screen_size.y);
	vec2 p = uv;

    vec3 cPos = vec3(0.0,0.0, 0.5 * TIME);
    //vec3 cPos = vec3(0.3*sin(TIME*0.8), 0.4*cos(TIME*0.3), -6.0 * TIME);
    vec3 cDir = normalize(vec3(0.0, 0.0, -1.0));
    vec3 cUp  = vec3(sin(TIME), 1.0, 0.0);
    vec3 cSide = cross(cDir, cUp);

    vec3 ray = normalize(cSide * p.x + cUp * p.y + cDir);


    float acc = 0.0;
    float acc2 = 0.0;
    float t = 0.0;
    for (int i = 0; i < 80; i++) {
        vec3 pos = cPos + ray * t;
        float dist = map(pos, cPos);
        dist = max(abs(dist), 0.02);
        float a = exp(-dist*3.0);
        if (mod(length(pos)+24.0*TIME, 30.0) < 3.0) {
            a *= 2.0;
            acc2 += a;
        }
        acc += a;
        t += dist * 0.5;
    }

    vec3 color = vec3(palette(length(uv)+TIME*time_mult,color_cell_a,color_cell_b,param_cell_c,param_cell_d));
    COLOR = vec4(color, 1.0 - t * 0.03);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
