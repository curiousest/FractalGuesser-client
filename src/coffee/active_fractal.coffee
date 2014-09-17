window.ActiveFractal = class extends Backbone.Model
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    zoom_multiplier: 4
    fractal_manager: 0
    
  constructor: (canvas_size) ->
    Backbone.Model.apply(@)
    @fractal_manager = new window.FractalManager(canvas_size)
    
  startLevel: (this_level) =>
    @fractal_manager.resetCanvas()
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@get('zoom_multiplier'), this_level)
    
  startGame: =>
    @startLevel(1)
  
  zoomIn: (new_top_left) ->
    @set 'zoom', @get('zoom') * @get('zoom_multiplier')
    @fractal_manager.setCanvas(new_top_left, @get('zoom'))

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
        <canvas id='canvasMandelbrot' width='600' height='500'> </canvas>
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
    draw($('#canvasMandelbrot')[0], [-2,1], [-1.5,1.5], pickColorHSV1, mandelbrotAlgorithm)
