window.RouteGenerator = class 

  fractal_manager = null
  dummy_canvas = null
  routes = null
  pixels_checked = 0
  has_colored_pixel = false
  
  constructor: ->
    @max_depth = 2
    @fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285)
    @routes = {max_depth: @max_depth}
    
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
        
  # breadth-first iteration through the routes object that inserts the data one route at a time into server_url
  insertRoutes: (server_url) =>
    route_queue = []
    route_queue.push({level: 0, route: '[', remaining_routes: @routes})
    route_id = -1
    current_level = 0
    while(route_queue.length > 0)
      current_route = route_queue.shift()
      route_id++
      if (current_route.level != current_level)
        current_level++
        console.log("Level " + current_level + " begins at id=" + route_id)
      $.ajax({
            url: server_url,
            type: "POST",
            crossDomain: true,
            data: {level: current_route.level, route: current_route.route + ']', route_id: route_id}
            dataType: "json",
      })
      if (current_route.level == @max_depth)
        continue
      for x_section in [0..3]
        for y_section in [0..3]
          if (current_route.remaining_routes[x_section] && 
          current_route.remaining_routes[x_section][y_section] && 
          !$.isEmptyObject(current_route.remaining_routes[x_section][y_section]))
            new_route = {level: current_route.level + 1, route: current_route.route, remaining_routes: current_route.remaining_routes[x_section][y_section]}
            # don't add a comma for the first section in the array
            if (new_route.route.length != 1)
              new_route.route = new_route.route + ','
            new_route.route = new_route.route + '{"x":' + x_section + ',"y":' + y_section + '}'  
            route_queue.push(new_route)
    console.log("Ends at id=" + route_id)
        
$(document).ready(->
  route_generator = new window.RouteGenerator
  route_generator.checkRoutes(route_generator.routes, 0)
  csrftoken = $.cookie('csrftoken')
  $.ajaxSetup({
    beforeSend: (xhr, settings) ->
      xhr.setRequestHeader("X-CSRFToken", csrftoken)
  })
  route_generator.insertRoutes('http://localhost:8000/api/insert/')
)

