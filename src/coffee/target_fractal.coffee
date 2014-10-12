window.TargetFractal = class extends Backbone.Model

  constructor: (canvas_size, active_fractal) ->
    Backbone.Model.apply(@)
    @SECTION_ROW_COUNT = active_fractal.SECTION_ROW_COUNT
    @SECTION_COLUMN_COUNT = active_fractal.SECTION_COLUMN_COUNT
    @CANVAS_PIXEL_WIDTH = active_fractal.CANVAS_PIXEL_WIDTH
    @CANVAS_PIXEL_HEIGHT = active_fractal.CANVAS_PIXEL_HEIGHT
    @x_section_size = @CANVAS_PIXEL_WIDTH / @SECTION_COLUMN_COUNT
    @y_section_size = @CANVAS_PIXEL_HEIGHT / @SECTION_ROW_COUNT
    @zoom_multiplier = active_fractal.get('zoom_multiplier')
    @fractal_manager = new window.FractalManager(canvas_size, @CANVAS_PIXEL_WIDTH, @CANVAS_PIXEL_HEIGHT)
  
  newRandomCanvas: (next_level) =>
    @fractal_manager.resetCanvas()
    for level in [1..next_level]
      do (level) =>
        section_coordinates = @getCanvasSectionCoordinates({
          x: Math.floor(Math.random() * 4)
          y: Math.floor(Math.random() * 4)
        })
        @fractal_manager.setCanvas(
          section_coordinates.top_left
          Math.pow(@zoom_multiplier, level)
          Math.pow(@zoom_multiplier, level - 1)
        )
    
  getCanvasSection: (coordinate) =>
    x_section = Math.floor(coordinate.x / @x_section_size)
    y_section = Math.floor(coordinate.y / @y_section_size)
    return {x: x_section, y: y_section}
  
  getCanvasSectionCoordinates: (section) =>
    return {
      top_left: {
        x: Math.ceil(section.x * @x_section_size)
        y: Math.ceil(section.y * @y_section_size)
      }
      bottom_right: {
        x: Math.ceil((section.x + 1) * @x_section_size)
        y: Math.ceil((section.y + 1) * @y_section_size)
      }
    }

window.TargetFractalView = class extends Backbone.View
  template: _.template("
    <div id='target-canvas'>
        <div class='target-mandelbrot' />
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    
    @fractal_manager_view = new window.FractalManagerView(@model.fractal_manager)
    
    Backbone.View.apply(@)
    
  initialize: ->
    @$el = $ '#target-fractal'
    @model.newRandomCanvas(1)
    @render()
    
    @fractal_manager_view.initialize()
    
  assign: (view, selector) -> 
    view.setElement($(selector))
    view.render()
  
  render: =>
    @$el.html(@template())
    @assign(@fractal_manager_view, '.target-mandelbrot')
