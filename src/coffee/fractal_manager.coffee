window.FractalManager = class extends Backbone.Model
  
  top_left: {x: 0, y: 0}
  bottom_right: {x: 0, y: 0}
  default_top_left: {x: 0, y: 0}
  default_bottom_right: {x: 0, y: 0}
  entire_width: 0
  entire_height: 0
  canvas: 0
  color_picker: 0
  fractal_algorithm: 0
  fractal_range: 0  
    
  constructor: (canvas_size) ->
  
    Backbone.Model.apply(@)
  
    @set 'default_top_left', canvas_size.top_left
    @set 'default_bottom_right', canvas_size.bottom_right
    @set 'top_left', canvas_size.top_left
    @set 'bottom_right', canvas_size.bottom_right
    @set 'entire_width', canvas_size.bottom_right.x - canvas_size.top_left.x
    @set 'entire_height', canvas_size.top_left.y - canvas_size.bottom_right.y
    
  drawCanvas: ->
    #fractal.drawCanvas(canvas, fractal_range.x, fractal_range.y, color_picker, fractal_algorithm)
    return 0
    
  setCanvas: (new_top_left, zoom) ->
    @set 'top_left', new_top_left
    @set 'bottom_right', {x: @get('top_left').x + @get('entire_width')/zoom, y: @get('top_left').y - @get('entire_height')/zoom}
    
  resetCanvas: ->
    @set 'top_left', @get 'default_top_left'
    @set 'bottom_right', @get 'default_bottom_right'
    
  renderCanvas: ->
    console.log('not yet')
