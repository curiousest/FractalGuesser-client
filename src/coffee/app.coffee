window.active = new window.ActiveFractal(MANDELBROT_CANVAS_SIZE)
window.activeView = new window.ActiveFractalView({model:active})
window.target = new window.TargetFractal(MANDELBROT_CANVAS_SIZE, window.active)
window.targetView = new window.TargetFractalView({model:target})

