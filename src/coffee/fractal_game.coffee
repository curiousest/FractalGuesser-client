window.FractalGame = class extends Backbone.Model
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  API_CANVAS_SIZE: {width: 400, height: 285}
  zoom_multiplier: 4
  target_route: []
  travelled_route: []
  clicks_remaining : 6
  
  defaults:
    zoom: 1
    score: 0
    round: 0
    fractal_game_message: "Click to zoom in. Try to zoom in to the exact location of the fractal on the left."
    
  constructor: (pixel_canvas_size, cartesian_canvas_size, cartesian_diagonal) ->
    Backbone.Model.apply(@)
    @cartesian_diagonal = cartesian_diagonal
    
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
    
  startRound: (this_round) =>
    @may_play_next_round = false
    @travelled_route = []
    @round_over = false
    
    if !this_round?
      this_round = @get('round') + 1
      
    @set 'round', this_round
    @set 'zoom', 1
    @clicks_remaining = 6
    
    @active_fractal_manager.resetCanvas()
    @set('fractal_game_message', "round " + @get('round') + " in progress...")
    $('#target-canvas').css('visibility', 'visible')
    $('#active-canvas').css('visibility', 'hidden')
    $('#next-round-button').css('visibility', 'hidden')
    
    @newRandomTargetCanvas(this_round)
        
  startGame: =>
    @set 'round', 0
    @set 'score', 0
    @startRound(1)
    
  roundFinished: (success) =>
    @round_over = true

    if (success)
      @set 'score', @get('score') + 100
      @set('fractal_game_message', "Perfect! Round " + @get('round') + ": 100 / 100. Continue to next round.")
    else
      active_c = @active_fractal_manager.getCenterCoordinate()
      target_c = @target_fractal.target_fractal_manager.getCenterCoordinate()
      distance = Math.sqrt(Math.pow(active_c.x - target_c.x, 2) + Math.pow(active_c.y - target_c.y, 2))
      round_score = 100 - 100 * Math.abs((@cartesian_diagonal - (9*distance))/@cartesian_diagonal)
      @set('fractal_game_message', "Round over. Round " + @get('round') + ": " + round_score + " / 100")
      @set 'score', @get('score') + round_score
      
    if (@get('round') != 3)
      @may_play_next_round = true
      $('#next-round-button').css('visibility', 'visible')
    else
      @set('fractal_game_message', @get('fractal_game_message') + " Game finished. Refresh to play again. Total score : " + @get('score') + "/300") 
  
  zoomIn: (picked_section) =>
    @travelled_route.push(picked_section) 
    new_zoom = @get('zoom') * @zoom_multiplier
    @active_fractal_manager.setCanvas(picked_section, new_zoom)
    
    # model state change causes the view to render
    @set 'zoom', new_zoom
    
    # if user has already finished the round and is just messing around zooming in
    if @may_play_next_round or @round_over
      return
      
    @clicks_remaining -= 1
    
    on_correct_route = false
    
    # if the user arrived at the target location, change the game state
    if (new_zoom == @target_fractal.zoom)
      on_correct_route = true
      for i in [0..@target_route.length - 1]
        if (@target_route[i].x != @travelled_route[i].x or @target_route[i].y != @travelled_route[i].y)
          on_correct_route = false
      if(on_correct_route)
        @roundFinished(true)
    
    # if the user has failed to arrive within the allotted clicks, change the game state
    if(@clicks_remaining == 0 and !on_correct_route)
      @roundFinished(false)
        
  back: () =>
    if @get('zoom') == 1 or @clicks_remaining == 0
      return
    @active_fractal_manager.previousCanvas()
    @travelled_route.pop()
    @set 'zoom', @get('zoom') / @zoom_multiplier
    @clicks_remaining -= 1
    if (@clicks_remaining == 0)
      @roundFinished(false)
      
  nextRoundButtonPressed: () =>
    if @may_play_next_round
      @startRound(@get('round') + 1)
      
  generateRoute: (success_function, error_function) =>
    next_section = 0
    $.ajax({
      url: window.fractal_api_url + "generate/mandelbrot/",
      type: "GET",
      success: (data) ->
        success_function(data)
      failure: error_function
    })
    
  newRandomTargetCanvas: (next_round) =>
    @target_fractal.target_fractal_manager.resetCanvas()
    @generateRoute( 
      (generated_route) =>
        @target_route = generated_route['route']
        round = 0
        for section in @target_route
          round++
          @target_fractal.target_fractal_manager.setCanvas(
            section
            Math.pow(@zoom_multiplier, round)
          )
        # the target fractal is rendered on this change, not when the whole fractal game is rendered 
        # (to avoid unecessary fractal rendering)
        @target_fractal.zoom = Math.pow(@zoom_multiplier, generated_route['level'])
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
      <button id='next-round-button' class='btn btn-success'>Play Next round</button>
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
      'clicks_remaining': @model.clicks_remaining
      'active_canvas_pixel_width': @model.active_canvas_pixel_width
      'active_canvas_pixel_height': @model.active_canvas_pixel_height
      'fractal_game_message' : @model.get('fractal_game_message')
    }))
    
    $('#toggle-target-fractal').on('click', @toggleVisibleFractal)
    $('#next-round-button').on('click', @model.nextRoundButtonPressed)
    $('#fractal-back-button').on('click', @model.back)

    @assign(@active_fractal_manager_view, '.active-mandelbrot')
    @assign(@fractal_sections_view, '.fractal-sections')

