
shader_type spatial;

uniform vec4 floor_color : source_color = vec4(0.12, 0.12, 0.12, 1.0);
uniform vec4 line_color : source_color = vec4(0.35, 0.35, 0.35, 1.0);

uniform float grid_size = 20.0;
uniform float line_width = 0.025;

void fragment() {
    vec2 grid = fract(UV * grid_size);

    vec2 edge = min(grid, 1.0 - grid);

    float line = 1.0 - step(
        line_width,
        min(edge.x, edge.y)
    );

    ALBEDO = mix(
        floor_color.rgb,
        line_color.rgb,
        line
    );
}
