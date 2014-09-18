window.ActiveFractal = class extends Backbone.Model
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    zoom_multiplier: 4
    fractal_manager: 0
    fractal_manager_view: 0
    
  constructor: (canvas_size) ->
    Backbone.Model.apply(@)
    @fractal_manager = new window.FractalManager(canvas_size)
    @fractal_manager_view = new window.FractalManagerView(@fractal_manager, '#active_mandelbrot')
    
  startLevel: (this_level) =>
    @fractal_manager.resetCanvas()
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@get('zoom_multiplier'), this_level)
    
  startGame: =>
    @startLevel(1)
  
  zoomIn: (new_top_left) ->
    new_zoom = @get('zoom') * @get('zoom_multiplier')
    @fractal_manager.setCanvas(new_top_left, new_zoom)
    @set 'zoom', new_zoom

window.ActiveFractalView = class extends Backbone.View
  template: _.template(
    "<div id='instructions'>
      Click to zoom in. Try to zoom in to the exact location of the fractal on the left.
    </div>
    <div class='canvas-header'>
      Current Level: <%= level %> clicks deep 
      Zoom at target location: x<%= max_zoom %>
    </div>
    <div id='active-canvas'>
        <canvas id='active_mandelbrot' width='400' height='400'> </canvas>
        <div id='active-zoom' class='zoom'><%= zoom %>x</div>
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    @$el = $ '#active-fractal'
    @render()
    
  initialize: ->
    @model.on('change', @render, @)
  
  render: =>
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'level': @model.get('level')
      'max_zoom': @model.get('max_zoom')
    }))
    @model.fractal_manager_view.render()
