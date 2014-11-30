window.fractal_api_url = "http://localhost:8000/api/"
window.fractalGame = new window.FractalGame({width: window.innerWidth, height: window.innerHeight}, MANDELBROT_CANVAS_SIZE)
window.fractalGameView = new window.FractalGameView({model:fractalGame})

