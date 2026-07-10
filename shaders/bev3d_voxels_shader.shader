shader_type spatial;
render_mode unshaded, skip_vertex_transform, cull_back;

// Input textures:
uniform sampler2D bev3d_geo_texture : hint_black;   // XYZ offset of voxel
uniform sampler2D bev3d_radii_texture : hint_black; // XXYY radii of voxel
uniform sampler2D bev3d_radii2_texture : hint_black; // XXYY radii of voxel

// Voxel transform and color configuration:
uniform vec3 voxel_origin = vec3(0,0,0);
uniform vec3 voxel_unit_x = vec3(1,0,0);
uniform vec3 voxel_unit_y = vec3(0,1,0);
uniform vec3 voxel_unit_z = vec3(0,0,1);
uniform float voxel_radius_scale = 2.0;

// Vertex to pixel shader interpolators:
varying vec4  normal_and_height; // xyz=normal, w=height

// Color fade controls:
uniform float bg_white_pct = 1; // is background mostly white
uniform vec4 fade_white_low : hint_color = vec4(0.9,0.9,0.9,1.0);
uniform vec4 fade_white_high: hint_color = vec4(0.7,0.7,0.7,1.0);
uniform vec4 fade_black_low: hint_color = vec4(0.2,0.2,0.2,1.0);
uniform vec4 fade_black_high: hint_color = vec4(0.4,0.4,0.4,1.0);
vec4 fade_low() { return mix(fade_black_low,fade_white_low,bg_white_pct); }
vec4 fade_high(){ return mix(fade_black_high,fade_white_high,bg_white_pct); }

// Constants
const float voxel_diameter_m = 0.33f; // should be 0.33 for full height voxels
const float voxel_encoded_center = 128.0 / 255.0;
const vec4  voxel_encoded_center4 = vec4(1,1,1,1) * voxel_encoded_center;
const float voxel_encoded_radius = (64.0f / 1.5f) / 255.0; // default voxel radius
const float voxel_max_cell_height = 7.0f;
const float voxel_max_world_height = voxel_max_cell_height * voxel_diameter_m;

void vertex()
{
	vec4 cubeCorner = vec4(VERTEX, 1.0);
	vec4 unitCenter = texture(bev3d_geo_texture, UV);
	vec4 voxelRadiiRaw = texture(bev3d_radii_texture, UV);
	vec4 voxelRadii2Raw = texture(bev3d_radii2_texture, UV);

	// decode the voxel radii into model space meters:
	vec3 unitCorner = (cubeCorner.xyz * 0.5) + vec3(0.5,0.5,0.5); // from -1:1 to 0:1
	vec4 voxelSizeXXYY = (voxelRadiiRaw - voxel_encoded_center4) / ( voxel_encoded_radius ); // 0:1 to voxel radius
	vec4 voxelSizeZZ   = (voxelRadii2Raw- voxel_encoded_center4) / ( voxel_encoded_radius ); // 0:1 to voxel radius
	vec3 scaledSize = vec3(
		mix(voxelSizeXXYY.x, voxelSizeXXYY.y, unitCorner.x), // X min to X max
		mix(voxelSizeXXYY.z, voxelSizeXXYY.w, unitCorner.y), // Y min to Y max
		mix(  voxelSizeZZ.x,   voxelSizeZZ.y, unitCorner.z)  // Z min to Z max
		);
	vec3 voxelOffset = (scaledSize / (128.0f)); // voxel radius to unit voxel position
	voxelOffset.y *= -1.0f; // because offsets have far/near flipped from voxel packing

	// decode the voxel positions into model space meters:
	vec3 unitOffsets = unitCenter.xyz + voxelOffset;
	vec3 localCoord =
		voxel_origin.xyz +
		(voxel_unit_x * unitOffsets.x) +
		(voxel_unit_y * unitOffsets.y) +
		(voxel_unit_z * unitOffsets.z);

	// to the pixel shader:
	normal_and_height = vec4( cubeCorner.xyz, localCoord.y );

	VERTEX = (MODELVIEW_MATRIX * vec4(localCoord,1)).xyz;
}

void fragment()
{
	// estimate which face this is, and then shade sides darker:
	vec3 norm = abs(normal_and_height.xyz);
	float lighting = ((norm.z >= norm.x) && (norm.z >= norm.y)) ? 1.0 :
			((norm.x > norm.y) ? 0.85 : 0.93);

	// color as a fade based on continuous height:
	float h = normal_and_height.w;
	float uh = min(1.0, h / voxel_max_world_height);
	vec3 color = mix(fade_high().rgb, fade_low().rgb, uh) * lighting;
	ALBEDO = color;
}