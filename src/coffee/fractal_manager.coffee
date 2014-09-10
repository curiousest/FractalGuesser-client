window.FractalManager = class extends Backbone.Model
  defaults:
    top_left: {x: 0, y: 1}
    bottom_right: {x: 1, y: 0}
    
  setCanvas: (new_top_left, zoom) ->
    @set 'top_left', new_top_left
    @set 'bottom_right', {x: @get('top_left').x + 1/zoom, y: @get('top_left').y - 1/zoom}
    
  renderCanvas: ->
    console.log('not yet')
