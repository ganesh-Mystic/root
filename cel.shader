shader_type spatial;
render_mode ambient_light_disabled,diffuse_toon,specular_toon,cull_back;
uniform bool use_shade = true;
uniform bool use_2shade = false;
uniform bool use_specular = false;
uniform bool use_rim = false;
uniform bool use_light_color = false;
uniform float shade_threshold;
uniform float second_shade;
uniform float light_color_intisity;
uniform float specular_glossiness : hint_range(1.0, 100.0, 0.1) = 15.0;
uniform float rim_threshold : hint_range(0.00, 1.0, 0.001) = 0.45;
uniform float rim_spread : hint_range(0.0, 1.0, 0.001) = 0.5;



void light()
{
	float NdotL = dot(NORMAL, LIGHT);
	float is_lit = step(shade_threshold, NdotL);
	vec3 diffuse;
	if (use_shade)
	{
		float shade_value = clamp(is_lit,0.1,0.5);
		diffuse = shade_value*ATTENUATION;
		
	}
	if (use_2shade)
	{
		if(NdotL<shade_threshold){
			NdotL = 0.1;
		}
		else if(NdotL>second_shade){
			NdotL = 0.5;
		}
		else
		{
			NdotL = 0.25;
		}
		diffuse =NdotL*ATTENUATION;
	}
	if (use_specular)
	{
		vec3 half = normalize(VIEW + LIGHT);
		float NdotH = dot(NORMAL, half);
		
		float specular_value = pow(NdotH * is_lit, specular_glossiness * specular_glossiness);
		diffuse += specular_value * ATTENUATION;
	}
	if (use_rim)
	{
		float iVdotN = 1.0 - dot(VIEW, NORMAL);
		float inverted_rim_threshold = 1.0 - rim_threshold;
		float inverted_rim_spread = 1.0 - rim_spread;
		
		float rim_value = iVdotN * pow(NdotL, inverted_rim_spread);
		rim_value = step(inverted_rim_threshold, rim_value);
		diffuse += LIGHT_COLOR.rgb * rim_value * is_lit;
	}
	if (use_light_color)
	{
		diffuse *= LIGHT_COLOR*light_color_intisity;
	}

	DIFFUSE_LIGHT += diffuse*ALBEDO;
}