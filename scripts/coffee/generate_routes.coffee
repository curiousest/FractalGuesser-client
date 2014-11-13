window.RouteGenerator = class 

  fractal_manager = null
  dummy_canvas = null
  bad_routes = null
  pixels_checked = 0
  has_colored_pixel = false
  
  constructor: ->
    @max_depth = 4
    @fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285)
    @bad_routes = {max_depth: @max_depth}
    
    @dummy_canvas = document.createElement('canvas')
    canvas_attribute = document.createAttribute("width")
    canvas_attribute.value="400"
    @dummy_canvas.setAttributeNode(canvas_attribute);
    canvas_attribute = document.createAttribute("height")
    canvas_attribute.value="285"
    @dummy_canvas.setAttributeNode(canvas_attribute);
    

  pickColorHSV1_CheckColor: (steps, n, Tr, Ti) =>
    @pixels_checked = @pixels_checked + 1
    if ( n == steps )
      return interiorColor

    v = smoothColor(steps, n, Tr, Ti);
    c = hsv_to_rgb(360.0*v/steps, 1.0, 1.0)
    if (c[0] != 255 || c[2] != 0)
      @has_colored_pixel = true
    c.push(255)
    return c
    
  checkRoutes: (current_route, depth) =>
    if depth > @max_depth
      return
    
    @pixels_checked = 0
    @has_colored_pixel = false

    # draw the section and find whether the route is ok
    draw(
      @dummy_canvas
      {
        x: @fractal_manager.get('top_left').x
        y: @fractal_manager.get('bottom_right').x
      }
      {
        x: @fractal_manager.get('top_left').y
        y: @fractal_manager.get('bottom_right').y
      }
      @pickColorHSV1_CheckColor
      mandelbrotAlgorithm
    )

    # if the route is not ok, return, leaving the current_route empty
    if !(@has_colored_pixel)
      return
    
    for x_section in [0..3]
      current_route[x_section] = {}
      
      for y_section in [0..3]
        current_route[x_section][y_section] = {}
        @fractal_manager.setCanvas({x: x_section, y: y_section}, Math.pow(4, depth + 1))
        
        @checkRoutes(current_route[x_section][y_section], depth + 1)
       
        @fractal_manager.previousCanvas()
        
$(document).ready(->
  route_generator = new window.RouteGenerator
  route_generator.checkRoutes(route_generator.bad_routes, 0)
  console.log(route_generator.bad_routes)
  str = JSON.stringify(route_generator.bad_routes)
  console.log(str)
)

