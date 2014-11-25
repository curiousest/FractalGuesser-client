window.fractal_api_url = "http://localhost:8000/api/"
window.fractalGame = new window.FractalGame({width: 800, height: 1000}, MANDELBROT_CANVAS_SIZE)
window.fractalGameView = new window.FractalGameView({model:fractalGame})

