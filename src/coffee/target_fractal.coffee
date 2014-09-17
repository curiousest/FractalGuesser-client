window.TargetFractal = class extends Backbone.Model
  defaults:
    zoom: 1
    coordinates: [0,0]
  
  zoomIn: (zoomIncrease) =>
    @set 'zoom', @get('zoom') * zoomIncrease

window.TargetFractalView = class extends Backbone.View
  template: _.template(
    "<div id='target-canvas'>
        <%= fractal %>
        <div id='target-zoom' class='zoom'><%= zoom %>x</div>
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    @$el = $('#target-fractal')
    @render()
    
  initialize: ->
    @model.on('change', @render, @)    
    
  render_fractal: ->
    return 'dud'
  
  render: =>
    @$el.html(@template({'zoom':@model.get('zoom'), 'fractal': @render_fractal()}))
