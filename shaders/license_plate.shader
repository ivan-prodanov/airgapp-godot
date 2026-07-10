shader_type canvas_item;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_text;
uniform sampler2D texture_noise;
uniform sampler2D texture_plate_skin;

// Defines rectangle of plate label in UV space, predefined based on mesh UVs
uniform vec2 plate_label_top_left_us;
uniform vec2 plate_label_size_us;
uniform vec2 plate_label_top_left_eu;
uniform vec2 plate_label_size_eu;
// Defines rectangle to display text in, pass into shader based on text dimensions
uniform vec2 text_bounds_top_left_us;
uniform vec2 text_bounds_size_us;
uniform vec2 text_bounds_top_left_eu;
uniform vec2 text_bounds_size_eu;
// Preserves rounded edges of plate label instead of filling rectangular region
uniform float plate_label_min_brightness;
uniform float noise_weight;

// Plate Color
uniform vec4 color_background 	: hint_color = vec4(0.06f, 0.06f, 0.06f, 1);
uniform vec4 color_font 		: hint_color = vec4(1.f);

varying vec2 plate_label_uv_us;
varying vec2 plate_label_uv_eu;
varying vec2 text_uv_us;
varying vec2 text_uv_eu;

void vertex() 
{
	plate_label_uv_us = (UV - plate_label_top_left_us) / plate_label_size_us;
	plate_label_uv_eu = (UV - plate_label_top_left_eu) / plate_label_size_eu;
	text_uv_us = (UV - text_bounds_top_left_us) / text_bounds_size_us;
	text_uv_eu = (UV - text_bounds_top_left_eu) / text_bounds_size_eu;
}

// plate_uv: describe the area of plate rect
// text_uv:  describe the area of text rect
vec4 colorPlateRectArea(vec2 plate_uv, vec2 text_uv)
{
	// Apply plate skin
	vec4 outColor = texture(texture_plate_skin, plate_uv);
	vec4 albedo_text = vec4(0);

	// Apply license number
	if (clamp(text_uv, 0.0, 0.999) == text_uv) 
	{ 	// plate text area
		albedo_text = texture(texture_text,text_uv);

		// Use default font color if color_font.a == 0
		albedo_text.rgb = mix(albedo_text.rgb, color_font.rgb, color_font.a);
	}

	outColor = mix(outColor, albedo_text, albedo_text.a);

	return outColor;
}

void fragment() 
{
	COLOR = texture(texture_albedo, UV);
	
	// Filter out the boundary
	if (COLOR.r > plate_label_min_brightness)
	{

		// Draw background color
		COLOR = mix(COLOR, vec4(color_background.rgb, 1.0f), color_background.a);
		
		// Draw font
		if (clamp(plate_label_uv_us, 0.0, 1.0) == plate_label_uv_us) { // US plate area
			COLOR += (texture(texture_noise, UV) - 0.5) * noise_weight;	
			vec4 albedo_text = colorPlateRectArea(plate_label_uv_us, text_uv_us);
			COLOR.rgb = mix(COLOR.rgb, albedo_text.rgb, albedo_text.a);	
		}
		else if (clamp(plate_label_uv_eu, 0.0, 1.0) == plate_label_uv_eu) { // EU plate area
			COLOR += (texture(texture_noise, UV) - 0.5) * noise_weight;	
			vec4 albedo_text = colorPlateRectArea(plate_label_uv_eu, text_uv_eu);
			COLOR.rgb = mix(COLOR.rgb, albedo_text.rgb, albedo_text.a);	
		}

	}
}
