window.FractalGame = class extends Backbone.Model
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  CANVAS_PIXEL_WIDTH: 400
  CANVAS_PIXEL_HEIGHT: 285
  zoom_multiplier: 4
  target_order: []
  on_correct_route: true
  clicks_remaining : 1
  
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
    @clicks_remaining = this_level
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@zoom_multiplier, this_level)
    @active_fractal_manager.resetCanvas()
    @set('fractal_game_message', "Level " + @get('level') + " in progress...")
    @newRandomTargetCanvas(this_level)
    
  startGame: =>
    @startLevel(1)
  
  zoomIn: (picked_section) =>
    # don't allow zooming again while zooming already in is in progress
    return if @zoom_lock
    @zoom_lock = true
    
    @clicks_remaining -= 1
    new_zoom = @get('zoom') * @zoom_multiplier
    @active_fractal_manager.setCanvas(picked_section, new_zoom)
    @set 'zoom', new_zoom
    correct_section = @target_order.shift()
    if !(correct_section.x == picked_section.x && correct_section.y == picked_section.y)
      @on_correct_route = false
    if (new_zoom == @get('max_zoom'))
      if(@on_correct_route)
        @set('fractal_game_message', "Correct! Level " + @get('level') + " completed...")
        setTimeout(
          => 
            @startLevel(@get('level') + 1)
            @zoom_lock = false
          1000
        )
      else
        @set('fractal_game_message', "Incorrect choice. Sorry, you picked the wrong route. Refresh to play again.")
      
    else
      @zoom_lock = false
      
  generateRoute: (next_level, success_function, error_function) =>
    if (next_level < 0 || next_level > 20)
      throw new error("Tried to generate route with invalid level.")
    next_section = 0
    $.ajax({
      url: window.fractal_api_url + "generate/" + next_level,
      type: "GET",
      success: (data) ->
        success_function(JSON.parse(data))
      failure: error_function
    })
    
  newRandomTargetCanvas: (next_level) =>
    @target_fractal.target_fractal_manager.resetCanvas()
    @generateRoute(next_level, 
      (generated_route) =>
        @target_order = generated_route
        level = 0
        for section in generated_route
          level++
          @target_fractal.target_fractal_manager.setCanvas(
            section
            Math.pow(@zoom_multiplier, level)
          )
        # the target fractal is rendered on this change, not when the fractal game is rendered
        @target_fractal.trigger('change')
        
      (failure_message) ->
        alert("Failed to reach fractal-generating server with error: " + failure_message)
    )  

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
      Clicks remaining: <span id='clicks_remaining'><%= clicks_remaining %></span>
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
      'clicks_remaining': @model.clicks_remaining
      'CANVAS_PIXEL_WIDTH': @model.CANVAS_PIXEL_WIDTH
      'CANVAS_PIXEL_HEIGHT': @model.CANVAS_PIXEL_HEIGHT
      'fractal_game_message' : @model.get('fractal_game_message')
    }))
    
    @assign(@active_fractal_manager_view, '.active-mandelbrot')
    @assign(@fractal_sections_view, '.fractal-sections')

