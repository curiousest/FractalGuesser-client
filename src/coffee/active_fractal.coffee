window.ActiveFractal = class extends Backbone.Model
  defaults:
    zoom: 1
    coordinates: [0,0]
    level: 1
    max_zoom: 2
    zoom_multiplier: 4
    
  startLevel: (this_level) =>
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@get('zoom_multiplier'), this_level)
    
  startGame: =>
    @startLevel(1)

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
        <%= fractal %>
        <div id='active-zoom' class='zoom'><%= zoom %>x</div>
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    $(document).on "ready", =>
      @$el = $ '#active-fractal'
      @render()
    
  initialize: ->
    @model.on('change', @render, @)
    
  render_fractal: ->
    return 'dud'
  
  render: =>
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'level': @model.get('level')
      'max_zoom': @model.get('max_zoom')
      'fractal': @render_fractal()
    }))
