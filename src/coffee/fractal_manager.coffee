window.FractalManager = class extends Backbone.Model
  
  top_left: {x: 0, y: 0}
  bottom_right: {x: 0, y: 0}
  default_top_left: {x: 0, y: 0}
  default_bottom_right: {x: 0, y: 0}
  entire_width: 0
  entire_height: 0
  canvas: 0
  color_picker: pickColorHSV1
  fractal_algorithm: mandelbrotAlgorithm
  fractal_range: 0
    
  constructor: (canvas_size) ->
  
    Backbone.Model.apply(@)
  
    @set 'default_top_left', canvas_size.top_left
    @set 'default_bottom_right', canvas_size.bottom_right
    @set 'top_left', canvas_size.top_left
    @set 'bottom_right', canvas_size.bottom_right
    @set 'entire_width', canvas_size.bottom_right.x - canvas_size.top_left.x
    @set 'entire_height', canvas_size.top_left.y - canvas_size.bottom_right.y
    
  setCanvas: (new_top_left, new_zoom, old_zoom, canvas_pixel_width, canvas_pixel_height) ->
    offset_from_old_top_left = {
      x: (new_top_left.x / canvas_pixel_width) * @get('entire_width')/old_zoom
      y: (new_top_left.y / canvas_pixel_height) * @get('entire_height')/old_zoom
    }
    old_top_left = @get('top_left')
    @set 'top_left', {
      x: old_top_left.x + offset_from_old_top_left.x
      y: old_top_left.y - offset_from_old_top_left.y
    }
    @set 'bottom_right', {
      x: old_top_left.x + offset_from_old_top_left.x + @get('entire_width')/new_zoom
      y: old_top_left.y - offset_from_old_top_left.y - @get('entire_height')/new_zoom
    }
    
  resetCanvas: ->
    @set 'top_left', @get 'default_top_left'
    @set 'bottom_right', @get 'default_bottom_right'
    
window.FractalManagerView = class extends Backbone.View
  defaults:
    canvas_selector: 0

  constructor: (@model, @canvas_selector) -> 
  
  render: =>
    draw(
      $(@canvas_selector)[0]
      {
        x: @model.get('top_left').x
        y: @model.get('bottom_right').x
      }
      {
        x: @model.get('top_left').y
        y: @model.get('bottom_right').y
      }
      @model.color_picker
      @model.fractal_algorithm
    )
