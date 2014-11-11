window.FractalGame = class extends Backbone.Model
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  CANVAS_PIXEL_WIDTH: 400
  CANVAS_PIXEL_HEIGHT: 285
  zoom_multiplier: 4
  target_order: []
  on_correct_route: true
  
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    fractal_game_message: "Click to zoom in. Try to zoom in to the exact location of the fractal on the left."
    
  constructor: (canvas_size) ->
    Backbone.Model.apply(@)
    @x_section_size = @CANVAS_PIXEL_WIDTH / @SECTION_COLUMN_COUNT
    @y_section_size = @CANVAS_PIXEL_HEIGHT / @SECTION_ROW_COUNT
    @active_fractal_manager = new window.FractalManager(canvas_size, @CANVAS_PIXEL_WIDTH, @CANVAS_PIXEL_HEIGHT)
    target_fractal_manager = new window.FractalManager(canvas_size, @CANVAS_PIXEL_WIDTH, @CANVAS_PIXEL_HEIGHT)
    @target_fractal = new window.TargetFractal(target_fractal_manager)
    
  startLevel: (this_level) =>
    @newRandomTargetCanvas(this_level)
    @active_fractal_manager.resetCanvas()
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@zoom_multiplier, this_level)
    
  endLevel: =>
    if(@on_correct_route)
      @startLevel(@get('level') + 1)
    else
      @set('fractal_game_message', "Incorrect choice. Sorry, you picked the wrong route. Refresh to try again...or keep zooming in...")
    
  startGame: =>
    @startLevel(1)
  
  zoomIn: (picked_section) =>
    # don't allow zooming again while zooming already in is in progress
    return if @zoom_lock
    @zoom_lock = true
    
    new_zoom = @get('zoom') * @zoom_multiplier
    @active_fractal_manager.setCanvas(picked_section, new_zoom)
    @set 'zoom', new_zoom
    correct_section = @target_order.shift()
    if !(correct_section.x == picked_section.x && correct_section.y == picked_section.y)
      @on_correct_route = false
    if (new_zoom == @get('max_zoom'))
      setTimeout(
        => 
          @endLevel()
          @zoom_lock = false
        1000
      )
    else
      @zoom_lock = false
      
  generateRoute: (next_level) =>
    if (next_level < 0 || next_level > 20)
      throw new error("Tried to generate route with invalid level.")
    route = []
    remaining_bad_routes = window.bad_routes
    next_section = 0
    
    for level in [1..next_level]
      next_section = 0
      until (next_section != 0)
        next_section = {
          x: Math.floor(Math.random() * 4)
          y: Math.floor(Math.random() * 4)
        }
        break if (level > window.bad_routes.max_depth)
        
        if (remaining_bad_routes[next_section.x] && remaining_bad_routes[next_section.x][next_section.y] && !$.isEmptyObject(remaining_bad_routes[next_section.x][next_section.y]))
          remaining_bad_routes = remaining_bad_routes[next_section.x][next_section.y]
        else
          next_section = 0
        
      @target_fractal.target_fractal_manager.setCanvas(
        next_section
        Math.pow(@zoom_multiplier, level)
      )
      route.push(next_section)
    
    return route
    
  newRandomTargetCanvas: (next_level) =>
    @target_fractal.target_fractal_manager.resetCanvas()
    @target_order = @generateRoute(next_level)
    
    # the target fractal is rendered on this change, not when the fractal game is rendered
    @target_fractal.trigger('change')

window.FractalGameView = class extends Backbone.View
  
  $canvas_el: 0
  current_section: {x:0, y:0}
  
  template: _.template(
    "<div id='fractal-game-message'>
      <%= fractal_game_message %>
    </div>
    <div class='canvas-header'>
      Current zoom: <span id='active-zoom' class='zoom'>x<%= zoom %></span> 
      <br/>
      Target zoom: <span id='target-zoom' class='zoom'>x<%= max_zoom %></span>
      <br/>
      Clicks remaining: <span id='remaining-clicks'><%= remaining_clicks %></span>
    </div>
    <div id='active-canvas' style='position:relative;'>
        <div class='active-mandelbrot' />
        <div class='fractal-sections' />

    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
 
    @fractal_sections = new window.FractalSections({
      width: @model.CANVAS_PIXEL_WIDTH
      height: @model.CANVAS_PIXEL_HEIGHT
      on_click_function: @model.zoomIn
    })
    @fractal_sections_view = new window.FractalSectionsView(@fractal_sections)
    @active_fractal_manager_view = new window.FractalManagerView(@model.active_fractal_manager)
    
    # the target fractal view is controlled by the FractalGameView, but it renders independently
    # because it can take very long to render and it doesn't need to render very often
    @target_fractal_view = new window.TargetFractalView({model: @model.target_fractal})
    
    Backbone.View.apply(@)
    
  initialize: =>
    @$el = $ '#active-fractal'
    @model.on('change', @render, @)
    @render()
    
    @fractal_sections_view.initialize()
    @active_fractal_manager_view.initialize()
    
    @model.newRandomTargetCanvas(1)
    @target_fractal_view.initialize()
    
  assign: (view, selector) -> 
    view.setElement($(selector))
    view.render()
    
  render: =>
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'max_zoom': @model.get('max_zoom')
      'remaining_clicks': @model.get('max_zoom')/@model.zoom_multiplier - Math.floor(@model.get('zoom')/@model.zoom_multiplier)
      'CANVAS_PIXEL_WIDTH': @model.CANVAS_PIXEL_WIDTH
      'CANVAS_PIXEL_HEIGHT': @model.CANVAS_PIXEL_HEIGHT
      'fractal_game_message' : @model.get('fractal_game_message')
    }))
    
    @assign(@active_fractal_manager_view, '.active-mandelbrot')
    @assign(@fractal_sections_view, '.fractal-sections')

