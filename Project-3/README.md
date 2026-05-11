# Project 3 — WebGL Shaders

A collection of progressively-built WebGL applications that generate geometry procedurally using vertex and fragment shaders. Each version builds on the previous one.

## Programs

1. [Wireframe Triangle](v1-triangle.html) — An equilateral triangle drawn as a wireframe using `gl.LINE_LOOP`. Vertices are placed procedurally with sine/cosine math in the vertex shader.

2. [10-Sided Filled Polygon](v2-polygon.html) — A filled convex decagon using `gl.TRIANGLE_FAN`. Introduces the uniform variable `N` (number of sides) to control the shape without changing the shader code.

3. [Five-Pointed Star](v3-star.html) — A five-pointed star built from the same triangle fan. Even-numbered vertex IDs are placed at the outer radius (tips) and odd-numbered IDs at the inner radius (valleys).

4. [Rotating Star](v4-rotating-star.html) — The same star, animated to spin continuously. A time uniform `t` is added to the angle computation each frame via `requestAnimationFrame`.

5. [Colorful Rotating Star](v5-colorful-star.html) — *(Extra credit)* The rotating star with color interpolation. The `radius` value is passed from the vertex shader to the fragment shader as a varying, and `mix()` blends from red at the center to gold at the tips.
