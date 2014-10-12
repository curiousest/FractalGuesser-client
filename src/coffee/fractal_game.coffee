window.FractalGame = class extends Backbone.Model
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  CANVAS_PIXEL_WIDTH: 400
  CANVAS_PIXEL_HEIGHT: 285
  zoom_multiplier: 4
  
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    
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
    console.log('complete me')
    
  startGame: =>
    @startLevel(1)
  
  zoomIn: (new_top_left) =>
    new_zoom = @get('zoom') * @zoom_multiplier
    @active_fractal_manager.setCanvas(new_top_left, new_zoom, @get('zoom'))
    if (new_zoom >= @get('max_zoom'))
      @endLevel()
    @set 'zoom', new_zoom
    
  newRandomTargetCanvas: (next_level) =>
    @target_fractal.target_fractal_manager.resetCanvas()
    for level in [1..next_level]
      do (level) =>
        section_coordinates = {
          x: Math.ceil(Math.floor(Math.random() * 4) * @x_section_size)
          y: Math.ceil(Math.floor(Math.random() * 4) * @y_section_size)
        }
        @target_fractal.target_fractal_manager.setCanvas(
          section_coordinates
          Math.pow(@zoom_multiplier, level)
          Math.pow(@zoom_multiplier, level - 1)
        )
        
    # the target fractal is rendered on this change, not when the fractal game is rendered
    @target_fractal.trigger('change')

window.FractalGameView = class extends Backbone.View
  
  $canvas_el: 0
  current_section: {x:0, y:0}
  
  template: _.template(
    "<div id='fractal-game-message'>
      Click to zoom in. Try to zoom in to the exact location of the fractal on the left.
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
    }))
    
    @assign(@active_fractal_manager_view, '.active-mandelbrot')
    @assign(@fractal_sections_view, '.fractal-sections')

