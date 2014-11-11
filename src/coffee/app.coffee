# must be hosted first $.getJSON( "http://dmhindson.pythonanywhere.com/static/bad_routes.json", (data)-> window.bad_routes = data)
window.fractalGame = new window.FractalGame(MANDELBROT_CANVAS_SIZE)
window.fractalGameView = new window.FractalGameView({model:fractalGame})

