vec4 effect(vec4 colour, Image texture, vec2 tex_coord, vec2 pixel_coords)
{
    number TAU = 6.28318530718;
    number DIRECTIONS = 16.0;
    number QUALITY = 3.0;
    number RADIUS = 0.005;

    vec4 sum = vec4(0.0);

    for (float d = 0.0; d < TAU; d += TAU / DIRECTIONS)
    {
        for (float i = 1.0 / QUALITY; i <= 1.0; i +=1.0 / QUALITY)
        {
            sum += texture2D(texture, tex_coord + vec2(cos(d), sin(d)) * RADIUS * i);      
        }
    }

    sum /= QUALITY * DIRECTIONS;
    return sum;
}
