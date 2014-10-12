window.FractalManager = class extends Backbone.Model
  default:
    top_left: {x: 0, y: 0}
    bottom_right: {x: 0, y: 0}
    default_top_left: {x: 0, y: 0}
    default_bottom_right: {x: 0, y: 0}
    entire_width: 0
    entire_height: 0
    pixel_width: 0
    pixel_height: 0
  canvas: 0
  color_picker: pickColorHSV1
  fractal_algorithm: mandelbrotAlgorithm
  fractal_range: 0
    
  constructor: (canvas_size, pixel_width, pixel_height) ->
  
    Backbone.Model.apply(@)
  
    @set 'default_top_left', canvas_size.top_left
    @set 'default_bottom_right', canvas_size.bottom_right
    @set 'top_left', canvas_size.top_left
    @set 'bottom_right', canvas_size.bottom_right
    @set 'entire_width', canvas_size.bottom_right.x - canvas_size.top_left.x
    @set 'entire_height', canvas_size.top_left.y - canvas_size.bottom_right.y
    @set 'pixel_width', pixel_width
    @set 'pixel_height', pixel_height
    
  setCanvas: (target_section, new_zoom) ->
    offset_from_old_top_left = {
      x: target_section.x * @get('entire_width')/new_zoom
      y: target_section.y * @get('entire_height')/new_zoom
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
    
  sameSection: (other_fractal_manager) ->
    this_top_left = @get('top_left')
    this_bottom_right = @get('bottom_right')
    other_top_left = other_fractal_manager.get('top_left')
    other_bottom_right = other_fractal_manager.get('bottom_right')
    return this_top_left.x == other_top_left.x && 
      this_top_left.y == other_top_left.y && 
      this_bottom_right.x == other_bottom_right.x && 
      this_bottom_right.y == other_bottom_right.y
    
  resetCanvas: ->
    @set 'top_left', @get 'default_top_left'
    @set 'bottom_right', @get 'default_bottom_right'
    
window.FractalManagerView = class extends Backbone.View
  template: _.template("<canvas style='position:absolute;' width='<%= pixel_width %>' height='<%= pixel_height %>'> </canvas>")

  constructor: (@model) -> 
    Backbone.View.apply(@)
  
  render: =>
    @$el.html(@template({
      'pixel_width': @model.get('pixel_width')
      'pixel_height': @model.get('pixel_height')
    }))
    draw(
      @$el.find('canvas')[0]
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
    return @$el
