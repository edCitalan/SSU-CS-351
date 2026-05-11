# Project 3 — Drawing Shapes with WebGL

This project is about drawing shapes directly in the browser using WebGL. Instead of using images or a game engine, everything is drawn from scratch using math — the browser figures out where to put each point and what color to make it.

Each version of the program builds on the one before it, starting simple and getting more complex step by step.

---

## Files

1. [v1-triangle.html](v1-triangle.html) — **Wireframe Triangle**
   Draws a simple triangle made of lines. The three corners are calculated using basic circle math so they're spaced evenly apart.

2. [v2-polygon.html](v2-polygon.html) — **10-Sided Filled Polygon**
   Instead of drawing lines, this one fills in a solid 10-sided shape. Think of it like cutting a pie into 10 equal slices that all meet in the middle. A variable controls how many sides the shape has, so it's easy to change.

3. [v3-star.html](v3-star.html) — **Five-Pointed Star**
   Takes the same pie-slice approach as the polygon but alternates between points that stick out far and points that stay close to the center. That alternating pattern is what makes it look like a star.

4. [v4-rotating-star.html](v4-rotating-star.html) — **Rotating Star**
   Same star as above, but now it spins. Every time the browser draws a new frame, the angle of each point is shifted a little bit, which makes the star look like it's continuously rotating.

5. [v5-colorful-star.html](v5-colorful-star.html) — **Colorful Rotating Star** *(Extra Credit)*
   The spinning star but with color. The tips of the star are gold and the center is red, and the color blends smoothly between them as you move from the middle outward.

---

## How to Run

Open any of the `.html` files directly in Chrome (press `Ctrl+O` to open a file). No installation or server needed.
