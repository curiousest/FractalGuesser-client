window.FractalGame = class extends Backbone.Model
  API_CANVAS_RATIO: 400/285
  ZOOM_MULTIPLIER: 4
  
  target_route: []
  travelled_route: []
  clicks_remaining: 6
  bonus_clicks: 0
  may_play_next_round: false
  round_over: false
  
  target_fractal: 0
  target_fractal_manager: 0
  active_fractal_manager: 0
  
  defaults:
    zoom: 1
    score: 0
    round: 0
    fractal_game_message: "Click to zoom in. Try to zoom in to the exact location of the fractal on the left."
    
  constructor: (pixel_canvas_size, cartesian_canvas_size, cartesian_diagonal, fractalAlgorithm, colorPicker) ->
    Backbone.Model.apply(@)
    @cartesian_diagonal = cartesian_diagonal
    
    # make the largest possible canvas at the proper aspect ratio that will fit in the canvas' pixel size
    if (pixel_canvas_size.width / pixel_canvas_size.height > @API_CANVAS_RATIO)
      @active_canvas_pixel_height = pixel_canvas_size.height
      @active_canvas_pixel_width = Math.floor(pixel_canvas_size.height * @API_CANVAS_RATIO)
    else
      @active_canvas_pixel_width = pixel_canvas_size.width
      @active_canvas_pixel_height = Math.floor(pixel_canvas_size.width / @API_CANVAS_RATIO)
    
    @target_canvas_pixel_width = @active_canvas_pixel_width
    @target_canvas_pixel_height = @active_canvas_pixel_height
    
    @active_fractal_manager = new window.FractalManager(cartesian_canvas_size, @active_canvas_pixel_width, @active_canvas_pixel_height, fractalAlgorithm, colorPicker)
    target_fractal_manager = new window.FractalManager(cartesian_canvas_size, @target_canvas_pixel_width, @target_canvas_pixel_height, fractalAlgorithm, colorPicker)
    @target_fractal = new window.TargetFractal(target_fractal_manager)
    
  startRound: (this_round) =>
    @may_play_next_round = false
    @travelled_route = []
    @round_over = false
    
    if !this_round?
      this_round = @get('round') + 1
      
    @set 'round', this_round
    @set 'zoom', 1
    @clicks_remaining = 6 + @bonus_clicks
    
    @active_fractal_manager.visible = false
    @target_fractal_manager.visible = true
    @active_fractal_manager.resetCanvas()
    if this_round == 1
      @set('fractal_game_message', "Instructions: switch between your target and current location.<br/>Click on your current canvas and try to zoom into the target.")
    else
      @set('fractal_game_message', "Round " + @get('round') + " in progress.")
    
    $('#next-round-button').css('visibility', 'hidden')
    
    @newRandomTargetCanvas(this_round)
        
  startGame: =>
    @set 'round', 0
    @set 'score', 0
    @bonus_clicks = 0
    @startRound(1)
    
  roundFinished: (success) =>
    @round_over = true

    if (success)
      @set 'score', @get('score') + 100 + @clicks_remaining
      @set('fractal_game_message', "Perfect! Round " + @get('round') + ": 100 / 100. Continue to next round.")
      @bonus_clicks = @clicks_remaining
    else
      active_c = @active_fractal_manager.getCenterCoordinate()
      target_c = @target_fractal.target_fractal_manager.getCenterCoordinate()
      distance = Math.sqrt(Math.pow(active_c.x - target_c.x, 2) + Math.pow(active_c.y - target_c.y, 2))
      round_score = 100 - 100 * Math.abs((@cartesian_diagonal - (9*distance))/@cartesian_diagonal)
      @set('fractal_game_message', "Round over. Round " + @get('round') + ": " + round_score + " / 100")
      @set 'score', @get('score') + round_score 
    
    if (@get('round') != 3)
      @may_play_next_round = true
    else
      @set('fractal_game_message', @get('fractal_game_message') + "<br/> Game finished. Total score : " + @get('score') + "/300") 
  
  zoomIn: (picked_section) =>
    # must be set before rendering
    if !(@may_play_next_round or @round_over)
      @clicks_remaining -= 1
      on_correct_route = false
      
    @travelled_route.push(picked_section) 
    new_zoom = @get('zoom') * @ZOOM_MULTIPLIER
    @active_fractal_manager.setCanvas(picked_section, new_zoom)
    
    # model state change causes the view to render
    @set 'zoom', new_zoom
    
    # if user has already finished the round and is just messing around zooming in
    if @may_play_next_round or @round_over
      return
      
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
    if @get('zoom') == 1
      return
      
    # must update before rendering
    clicks_remaining_before = @clicks_remaining
    if clicks_remaining_before > 0
      @clicks_remaining -= 1
    
    @active_fractal_manager.previousCanvas()
    @travelled_route.pop()
    @set 'zoom', @get('zoom') / @ZOOM_MULTIPLIER
    
    if (clicks_remaining_before == 1)
      @roundFinished(false)
      
  playNextRound: () =>
    if @may_play_next_round
      @startRound(@get('round') + 1)
    else if @round_over
      @startGame()
      
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
            Math.pow(@ZOOM_MULTIPLIER, round)
          )
        # the target fractal is rendered on this change, not when the whole fractal game is rendered 
        # (to avoid unecessary fractal rendering)
        @target_fractal.zoom = Math.pow(@ZOOM_MULTIPLIER, generated_route['level'])
        @target_fractal.trigger('change')
        $('#target-fractal').css('visibility', 'visible')
        
      (failure_message) ->
        alert("Failed to reach fractal-generating server with error: " + failure_message)
    )
    
  toggleVisibleFractal: () =>
    active_fractal_manager.toggleVisible()
    target_fractal_manager.toggleVisible()

window.FractalGameView = class extends Backbone.View
  
  $canvas_el: 0
  current_section: {x:0, y:0}
  
  template: _.template(
    "
    <div class='fractal-menu'>
      <button id='toggle-target-fractal' class='btn fractal-game-btn'>Show/Hide Target</button>
      <button id='fractal-back-button' class='btn fractal-game-btn'>Back</button>
      <button id='next-round-button' class='btn btn-success fractal-game-btn' style='visibility: <%= next_round_visible %>;'>Play Next round</button>
    </div>
    <div class='fractal-info'>
      <span id='clicks-remaining' class='fractal-game-text'>Clicks left: <%= clicks_remaining %></span>
      <br/>
      <span id='active-zoom' class='zoom fractal-game-text'>Zoom: x<%= zoom %></span>    
      <br/>
      <span class='fractal-game-text' id='fractal-game-message'>
        <%= fractal_game_message %>
      </span>
    </div>
    <div id='active-canvas' style='position:relative;'>
        <div class='fractal-canvas-holder' />
        <div class='fractal-sections' />
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
  
  # ugly, but necessary to avoid re-rendering fractals when trying to perform this simple toggle
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
      'next_round_visible' : if @model.round_over then 'visible' else 'hidden'
    }))
    
    $('#toggle-target-fractal').on('click', @toggleVisibleFractal)
    $('#next-round-button').on('click', @model.playNextRound)
    $('#fractal-back-button').on('click', @model.back)

    @assign(@active_fractal_manager_view, '.fractal-canvas-holder')
    @assign(@fractal_sections_view, '.fractal-sections')

