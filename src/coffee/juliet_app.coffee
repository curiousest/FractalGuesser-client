window.fractal_api_url = "http://localhost:8000/api/"
window.fractalGame = new window.FractalGame({width: window.innerWidth, height: window.innerHeight}, JULIET_CANVAS_SIZE, JULIET_CANVAS_DIAGONAL, julietAlgorithm, pickColorHSV1)
window.fractalGameView = new window.FractalGameView({model:fractalGame})

