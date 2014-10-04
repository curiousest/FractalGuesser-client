window.target = new window.TargetFractal(MANDELBROT_CANVAS_SIZE)
window.targetView = new window.TargetFractalView({model:target})
window.active = new window.ActiveFractal(MANDELBROT_CANVAS_SIZE)
window.activeView = new window.ActiveFractalView({model:active})
window.activeView.drawFractal()
window.targetView.drawFractal()

