// Generated by CoffeeScript 1.8.0
(function() {
  window.fractal_api_url = "http://localhost:8000/api/";

  window.fractalGame = new window.FractalGame({
    width: window.innerWidth,
    height: window.innerHeight
  }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL, mandelbrotAlgorithm, pickColorHSV1Gradient);

  window.fractalGameView = new window.FractalGameView({
    model: fractalGame
  });

}).call(this);
