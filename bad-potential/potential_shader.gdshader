shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.8, 1.0, 1.0); // Glow color
uniform float glow_radius : hint_range(1.0, 64.0, 0.5) = 6.0;        // How far the glow extends (in pixels)
uniform float glow_intensity : hint_range(0.0, 5.0, 0.1) = 2.0;     // Glow brightness multiplier

void fragment() {
    vec4 text_color = COLOR;
    
    // Sample surrounding pixels to approximate a radial blur/glow
    float alpha_sum = 0.0;
    float samples = 0.0;
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;

    // 16-point radial sampling
    for (float angle = 0.0; angle < 6.28318; angle += 0.3927) { // 16 radial directions
        for (float r = 1.0; r <= glow_radius; r += 1.0) {
            vec2 offset = vec2(cos(angle), sin(angle)) * r * pixel_size;
            float sample_alpha = texture(TEXTURE, UV + offset).a;
            
            // Weight samples by distance (closer pixels contribute more)
            float falloff = 1.0 - (r / (glow_radius + 1.0));
            alpha_sum += sample_alpha * falloff;
            samples += falloff;
        }
    }

    float glow_alpha = clamp((alpha_sum / samples) * glow_intensity, 0.0, 1.0);

    // Blend outer glow underneath original text
    vec4 glow = vec4(glow_color.rgb, glow_color.a * glow_alpha);
    
    // Alpha compositing: original text over glow
    COLOR.rgb = mix(glow.rgb, text_color.rgb, text_color.a);
    COLOR.a = max(glow.a, text_color.a);
}