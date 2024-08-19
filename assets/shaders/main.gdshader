shader_type canvas_item;

uniform vec2 offset;
uniform float alpha = 1.0;
uniform sampler2D text_img;
uniform float mult_size : hint_range( 0.01, 100 ) = 1.0;
uniform float fract_ampl : hint_range( 1.0, 10.0 ) = 2.0;
uniform float pattern_size : hint_range( 1.0, 30.0 ) = 8.0;
uniform float light_beam_size : hint_range( 0.0001, 0.02 ) = 0.01;
uniform float back_light_fact : hint_range( 0.1, 0.9 ) = 0.5;
uniform float time_mult : hint_range( 0.1, 0.9 ) = 0.4;
uniform	vec3 color_a : source_color = vec3( 0.047, 0.047, 0.322 );
uniform	vec3 color_b : source_color = vec3( 0.129, 0.039, 0.122);
uniform	vec3 param_c : source_color = vec3( 2.228, 0.0,0.0);
uniform	vec3 param_d : source_color = vec3( 0.377, 1.527,1.897);

uniform float PaletteRGBSize = 4.;// number of values possible for each R, G, B.
uniform float ResolutionDivisor = 2.;
uniform vec4 date;
#define USE_BAYER4x4
//#define USE_BAYER8x8
//#define USE_NOISE
//#define USE_ANIM_NOISE

float quantize(float inp, float period)
{
    return floor((inp+period/2.)/period)*period;
}


float bayer4x4(vec2 uvScreenSpace)
{
	vec2 bayerCoord = floor(uvScreenSpace/ResolutionDivisor);
    bayerCoord = mod(bayerCoord, 4.);
    const mat4 bayerMat = mat4(
    vec4(1,9,3,11),
    vec4(13,5,15,7),
    vec4(4,12,2,10),
    vec4(16,8,14,6)) / 16.;
    int bayerIndex = int(bayerCoord.x + bayerCoord.y * 4.);
    if(bayerIndex == 0) return bayerMat[0][0];
    if(bayerIndex == 1) return bayerMat[0][1];
    if(bayerIndex == 2) return bayerMat[0][2];
    if(bayerIndex == 3) return bayerMat[0][3];
    if(bayerIndex == 4) return bayerMat[1][0];
    if(bayerIndex == 5) return bayerMat[1][1];
    if(bayerIndex == 6) return bayerMat[1][2];
    if(bayerIndex == 7) return bayerMat[1][3];
    if(bayerIndex == 8) return bayerMat[2][0];
    if(bayerIndex == 9) return bayerMat[2][1];
    if(bayerIndex == 10) return bayerMat[2][2];
    if(bayerIndex == 11) return bayerMat[2][3];
    if(bayerIndex == 12) return bayerMat[3][0];
    if(bayerIndex == 13) return bayerMat[3][1];
    if(bayerIndex == 14) return bayerMat[3][2];
    if(bayerIndex == 15) return bayerMat[3][3];

    return 10.;// impossible
}

float bayer8x8(vec2 uvScreenSpace)
{
    return texture(text_img, uvScreenSpace/(ResolutionDivisor*8.)).r;
}

vec3 getSceneColor(vec2 uv)
{
    return texture(text_img, uv).rgb;
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}




vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d){
	return a + b * cos(6.28318*(c*t*d));
}

// Called for every pixel the material is visible on.
void fragment() {
	//Init UV
	vec2 uv = (SCREEN_UV * 2.0)-1.0;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	uv.x *= screen_size.x/screen_size.y ;
	uv *= mult_size;
	uv += offset;
	uv = mod(uv + vec2(1, 1), 2) - vec2(1, 1);
	vec2 uv0 = uv;
	
	

	
	
	//Colors
	vec3 final_color = vec3(0.0);
	
	// Itération for fractal pattern
	for(float f = 0.0; f< fract_ampl; f++){
		uv = fract(uv *1.5)-0.5;
		
		
		float local_dist = length(uv) * exp(-length(uv0));
		
		vec3 color = palette(length(uv0)+f*0.4+TIME*time_mult,color_a,color_b,param_c,param_d);
		
		local_dist = sin(local_dist*pattern_size+TIME*time_mult)/pattern_size;
		local_dist = abs(local_dist);
		local_dist = pow(light_beam_size / local_dist, back_light_fact);
		
		final_color += color * color * local_dist;
	}

	
		//Quantize
	// space between values of the dest palette
    vec3 quantizationPeriod = vec3(1./(PaletteRGBSize-1.));
    
	vec2 uvPixellated = floor(FRAGCOORD.xy / ResolutionDivisor)*ResolutionDivisor;
    
    // original color panel---------------------
    vec3 originalCol = getSceneColor(uv);
    
    // dithered panel---------------------
    //vec3 dc = getSceneColor(uvPixellated / screen_size.xy);
	vec3 dc = final_color;
	
    // apply bayer matrix, perturbing the original color values.
#ifdef USE_BAYER4x4
    dc += (bayer4x4(FRAGCOORD.xy)-.5)*(quantizationPeriod);
#endif
#ifdef USE_BAYER8x8
	dc += (bayer8x8(FRAGCOORD.xy)-.5)*(quantizationPeriod);
#endif
#ifdef USE_NOISE
	dc += (rand(uvPixellated)-.5)*(quantizationPeriod);
#endif
#ifdef USE_ANIM_NOISE
	dc += (rand(vec2(rand(uvPixellated),date.w))-.5)*(quantizationPeriod);
#endif
    // quantize color to palette
    dc = vec3(
        quantize(dc.r, quantizationPeriod.r),
        quantize(dc.g, quantizationPeriod.g),
        quantize(dc.b, quantizationPeriod.b)
            );
   
    //quantize to palette (raw quantization panel)---------------------
    //vec3 qc = getSceneColor(uvPixellated / screen_size.xy);
	//vec3 qc = final_color;
    //qc = vec3(
        //quantize(qc.r, quantizationPeriod.r),
        //quantize(qc.g, quantizationPeriod.g),
        //quantize(qc.b, quantizationPeriod.b)
            //);
	
	
    COLOR = vec4(dc,alpha);
}




//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
