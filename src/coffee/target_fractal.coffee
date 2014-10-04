window.TargetFractal = class extends Backbone.Model
  defaults:
    zoom: 1
    fractal_manager: 0
    fractal_manager_view: 0

  constructor: (canvas_size) ->
    Backbone.Model.apply(@)
    @fractal_manager = new window.FractalManager(canvas_size)
    @fractal_manager_view = new window.FractalManagerView(@fractal_manager, '#target_mandelbrot')
    
  zoomTo: (top_left, new_zoom) ->
    @fractal_manager.setCanvas(top_left, new_zoom)
    @set 'zoom', new_zoom

window.TargetFractalView = class extends Backbone.View
  template: _.template("
    <div id='target-canvas'>
        <canvas id='target_mandelbrot' width='400' height='400'> </canvas>
        <div id='target-zoom' class='zoom'><%= zoom %>x</div>
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    @$el = $('#target-fractal')
    @render()
    
  initialize: ->
    @model.on('change', @render, @)    
  
  render: =>
    @$el.html(@template({'zoom':@model.get('zoom')}))
  
  drawFractal: ->
    @model.fractal_manager_view.render()
