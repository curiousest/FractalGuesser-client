window.TargetFractal = class extends Backbone.Model
  defaults:
    zoom: 1

  constructor: (canvas_size, active_fractal) ->
    Backbone.Model.apply(@)
    @SECTION_ROW_COUNT = active_fractal.SECTION_ROW_COUNT
    @SECTION_COLUMN_COUNT = active_fractal.SECTION_COLUMN_COUNT
    @CANVAS_PIXEL_WIDTH = active_fractal.CANVAS_PIXEL_WIDTH
    @CANVAS_PIXEL_HEIGHT = active_fractal.CANVAS_PIXEL_HEIGHT
    @x_section_size = @CANVAS_PIXEL_WIDTH / @SECTION_COLUMN_COUNT
    @y_section_size = @CANVAS_PIXEL_HEIGHT / @SECTION_ROW_COUNT
    @fractal_manager = new window.FractalManager(canvas_size)
    @fractal_manager_view = new window.FractalManagerView(@fractal_manager, '#target_mandelbrot')
    
  zoomTo: (top_left, new_zoom) =>
    @fractal_manager.setCanvas(top_left, new_zoom, @get('zoom'), @CANVAS_PIXEL_WIDTH, @CANVAS_PIXEL_HEIGHT)
    @set 'zoom', new_zoom
    
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
        <canvas id='target_mandelbrot' width='<%= CANVAS_PIXEL_WIDTH %>' height='<%= CANVAS_PIXEL_HEIGHT %>'> </canvas>
        <div id='target-zoom' class='zoom'><%= zoom %>x</div>
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    @$el = $('#target-fractal')
    @render()
    
  initialize: ->
    @model.on('change', @render, @)    
  
  render: =>
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'CANVAS_PIXEL_WIDTH': @model.CANVAS_PIXEL_WIDTH
      'CANVAS_PIXEL_HEIGHT': @model.CANVAS_PIXEL_HEIGHT
    }))
  
  drawFractal: ->
    @model.fractal_manager_view.render()
