window.FractalGame = class extends Backbone.Model
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  API_CANVAS_SIZE: {width: 400, height: 285}
  zoom_multiplier: 4
  target_route: []
  travelled_route: []
  clicks_remaining : 1
  
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    fractal_game_message: "Click to zoom in. Try to zoom in to the exact location of the fractal on the left."
    
  constructor: (pixel_canvas_size, cartesian_canvas_size) ->
    Backbone.Model.apply(@)
    
    # make the largest possible canvas at the proper aspect ratio that will fit in the canvas' pixel size
    if (pixel_canvas_size.width / pixel_canvas_size.height > @API_CANVAS_SIZE.width / @API_CANVAS_SIZE.height)
      @active_canvas_pixel_height = pixel_canvas_size.height
      @active_canvas_pixel_width = Math.floor(pixel_canvas_size.height * (@API_CANVAS_SIZE.width / @API_CANVAS_SIZE.height))
    else
      @active_canvas_pixel_width = pixel_canvas_size.width
      @active_canvas_pixel_height = Math.floor(pixel_canvas_size.width * (@API_CANVAS_SIZE.height / @API_CANVAS_SIZE.width))
    
    @target_canvas_pixel_width = @active_canvas_pixel_width
    @target_canvas_pixel_height = @active_canvas_pixel_height
    
    @active_fractal_manager = new window.FractalManager(cartesian_canvas_size, @active_canvas_pixel_width, @active_canvas_pixel_height)
    target_fractal_manager = new window.FractalManager(cartesian_canvas_size, @target_canvas_pixel_width, @target_canvas_pixel_height)
    @target_fractal = new window.TargetFractal(target_fractal_manager)
    
  startLevel: (this_level) =>
    @may_play_next_level = false
    @travelled_route = []
    @level_over = false
    @clicks_remaining = this_level + 2
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@zoom_multiplier, this_level)
    @active_fractal_manager.resetCanvas()
    @set('fractal_game_message', "Level " + @get('level') + " in progress...")
    $('#target-canvas').css('visibility', 'visible')
    $('#active-canvas').css('visibility', 'hidden')
    $('#next-level-button').css('visibility', 'hidden')
    @newRandomTargetCanvas(this_level)
        
  startGame: =>
    @startLevel(1)
    
  levelFinished: (success) =>
    if (success)
      @set('fractal_game_message', "Correct! Level " + @get('level') + " completed...")
      $('#next-level-button').css('visibility', 'visible')
      @may_play_next_level = true
    else
      @set('fractal_game_message', "Incorrect choice. Sorry, you picked the wrong route. Refresh to play again.")
      @may_play_next_level = false
      @level_over = true
  
  zoomIn: (picked_section) =>
    @travelled_route.push(picked_section) 
    new_zoom = @get('zoom') * @zoom_multiplier
    @active_fractal_manager.setCanvas(picked_section, new_zoom)
    
    # model state change causes the view to render
    @set 'zoom', new_zoom
    
    # if user has already finished the level and is just messing around zooming in
    if @may_play_next_level or @level_over
      return
      
    @clicks_remaining -= 1
    
    on_correct_route = false
    
    # if the user arrived at the target location, change the game state
    if (new_zoom == @get('max_zoom'))
      on_correct_route = true
      for i in [0..@target_route.length - 1]
        if (@target_route[i].x != @travelled_route[i].x or @target_route[i].y != @travelled_route[i].y)
          on_correct_route = false
      if(on_correct_route)
        @levelFinished(true)
    
    return false
    
    # if the user has failed to arrive within the allotted clicks, change the game state
    if(@clicks_remaining == 0 and !on_correct_route)
      @levelFinished(false)
        
  back: () =>
    if @get('zoom') == 1 or @clicks_remaining == 0
      return
    @active_fractal_manager.previousCanvas()
    @travelled_route.pop()
    @set 'zoom', @get('zoom') / @zoom_multiplier
    @clicks_remaining -= 1
    if (@clicks_remaining == 0)
      @levelFinished(false)
      
  nextLevelButtonPressed: () =>
    if @may_play_next_level
      @startLevel(@get('level') + 1)
      $('#next-level-button').css('visibility', 'hidden')
      
  generateRoute: (next_level, success_function, error_function) =>
    if (next_level < 0 || next_level > 20)
      throw new error("Tried to generate route with invalid level.")
    next_section = 0
    $.ajax({
      url: window.fractal_api_url + "generate/mandelbrot/" + next_level,
      type: "GET",
      success: (data) ->
        success_function(JSON.parse(data))
      failure: error_function
    })
    
  newRandomTargetCanvas: (next_level) =>
    @target_fractal.target_fractal_manager.resetCanvas()
    @generateRoute(next_level, 
      (generated_route) =>
        @target_route = generated_route
        level = 0
        for section in generated_route
          level++
          @target_fractal.target_fractal_manager.setCanvas(
            section
            Math.pow(@zoom_multiplier, level)
          )
        # the target fractal is rendered on this change, not when the whole fractal game is rendered 
        # (to avoid unecessary fractal rendering)
        @target_fractal.zoom = Math.pow(@zoom_multiplier, level)
        @target_fractal.trigger('change')
        $('#target-fractal').css('visibility', 'visible')
        
      (failure_message) ->
        alert("Failed to reach fractal-generating server with error: " + failure_message)
    )  

window.FractalGameView = class extends Backbone.View
  
  $canvas_el: 0
  current_section: {x:0, y:0}
  
  template: _.template(
    "
    <div class='fractal-header'>
      <button id='toggle-target-fractal' class='btn'>Show/Hide Target</button>
      <button id='fractal-back-button' class='btn'>Back</button>
      <button id='next-level-button' class='btn btn-success'>Play Next Level</button>
      <span class='fractal-game-text' id='fractal-game-message'>
        <%= fractal_game_message %>
      </span>
    </div>
    <div id='active-canvas' style='position:relative;'>
        <div class='active-mandelbrot' />
        <div class='fractal-sections' />
        <span id='active-zoom' class='zoom fractal-game-text'>x<%= zoom %></span> 
        <span id='clicks-remaining' class='fractal-game-text'>Clicks: <%= clicks_remaining %></span>
    </div>
  ")

  constructor: (options={}) ->
    {@model, @classname} = options
 
    @fractal_sections = new window.FractalSections({
      width: @model.active_canvas_pixel_width
      height: @model.active_canvas_pixel_height
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
    
    @model.startGame()
    
  assign: (view, selector) -> 
    view.setElement($(selector))
    view.render()
    
  toggleVisibleFractal: () ->
    target_fractal = $('#target-canvas')
    active_fractal = $('#active-canvas')
    if (target_fractal.css('visibility') == 'hidden')
      target_fractal.css('visibility', 'visible')
      active_fractal.css('visibility', 'hidden')
    else
      target_fractal.css('visibility', 'hidden')
      active_fractal.css('visibility', 'visible')
    
  render: =>
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'max_zoom': @model.get('max_zoom')
      'clicks_remaining': @model.clicks_remaining
      'active_canvas_pixel_width': @model.active_canvas_pixel_width
      'active_canvas_pixel_height': @model.active_canvas_pixel_height
      'fractal_game_message' : @model.get('fractal_game_message')
    }))
    
    $('#toggle-target-fractal').on('click', @toggleVisibleFractal)
    $('#next-level-button').on('click', @model.nextLevelButtonPressed)
    $('#fractal-back-button').on('click', @model.back)

    @assign(@active_fractal_manager_view, '.active-mandelbrot')
    @assign(@fractal_sections_view, '.fractal-sections')

