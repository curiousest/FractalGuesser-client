window.FractalSection = class extends Backbone.Model
  top_left: {x: 0, y: 0}
  width: 0
  height: 0
  on_click_function: 0
    
  constructor: (options={}) ->
    Backbone.Model.apply(@)
    { @top_left
      @width
      @height
      @on_click_function} = options
      
window.FractalSectionView = class extends Backbone.View

  initialize: =>
    @el.setAttribute('style',
      'top: ' + @model.top_left.y + 'px; ' +
      'left: ' + @model.top_left.x + 'px; ' +
      'border: 1px; ' +
      'border-style: solid;' +
      'min-width: ' + @model.width + 'px; ' +
      'min-height: ' + @model.height + 'px; '+
      'position: absolute;'
    )
    @$el.html('&nbsp')
    @$el.on('click', =>@model.on_click_function(@model.top_left))

  render: => return @$el
  

window.FractalSections = class extends Backbone.Collection
  model: window.FractalSection
  sections: 4
  width: 0
  height: 0
    
  constructor: (options) ->
    super
    @pop()
    {@width, @height} = options
    for x_offset in [0..@sections-1]
      section_width = @width/@sections
      for y_offset in [0..@sections-1]
        section_height = @height/@sections
        top_left = {
            x: Math.floor(x_offset * section_width)
            y: Math.floor(y_offset * section_height)
          }
        fractalSection = new window.FractalSection(
          top_left: top_left 
          width: Math.floor(section_width) - 1
          height: Math.floor(section_height) - 1
          on_click_function: options.on_click_function
        )
        @add(fractalSection)         

window.FractalSectionsView = class extends Backbone.View 
  constructor: (@collection, @$el) ->
  
  initialize: =>
    @$el = $(@$el)
    @collection.forEach(
      (section) =>
        sectionView = new window.FractalSectionView({model: section})
        @$el.append(sectionView.render())
    )

window.ActiveFractal = class extends Backbone.Model
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    zoom_multiplier: 4
    
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
  
  zoomIn: (new_top_left) =>
    new_zoom = @get('zoom') * @get('zoom_multiplier')
    @fractal_manager.setCanvas(new_top_left, new_zoom)
    @set 'zoom', new_zoom

window.ActiveFractalView = class extends Backbone.View
  
  $canvas_el: 0
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  CANVAS_PIXEL_WIDTH: 400
  CANVAS_PIXEL_HEIGHT: 400
  x_section_size: 0
  y_section_size: 0
  current_section: {x:0, y:0}
  
  template: _.template(
    "<div id='instructions'>
      Click to zoom in. Try to zoom in to the exact location of the fractal on the left.
    </div>
    <div class='canvas-header'>
      Current Level: <%= level %> clicks deep 
      Zoom at target location: x<%= max_zoom %>
    </div>
    <div id='active-canvas' style='position:relative;'>
        <canvas id='active_mandelbrot' style='position:absolute;' width='<%= CANVAS_PIXEL_WIDTH %>' height='<%= CANVAS_PIXEL_HEIGHT %>'> </canvas>
        <div id='fractal-sections' />

        <div id='active-zoom' class='zoom'><%= zoom %>x</div>
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    @$el = $ '#active-fractal'
    @render()
    @$canvas_el = $ '#active_mandelbrot'
    @x_section_size = @CANVAS_PIXEL_WIDTH / @SECTION_COLUMN_COUNT
    @y_section_size = @CANVAS_PIXEL_HEIGHT / @SECTION_ROW_COUNT
    @fractal_sections = new window.FractalSections({
      width: @CANVAS_PIXEL_WIDTH
      height: @CANVAS_PIXEL_HEIGHT
      on_click_function: @model.zoomIn
    })
    @fractal_sections_view = new window.FractalSectionsView(@fractal_sections, '#fractal-sections')
    Backbone.View.apply(@)
    
  initialize: =>
    @fractal_sections_view.initialize()
    @model.on('change', @render, @)
    @render()
    
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
    
  render: =>
    @drawFractal()
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'level': @model.get('level')
      'max_zoom': @model.get('max_zoom')
      'CANVAS_PIXEL_WIDTH': @CANVAS_PIXEL_WIDTH
      'CANVAS_PIXEL_HEIGHT': @CANVAS_PIXEL_HEIGHT
    }))
  
  drawFractal: ->
    @model.fractal_manager_view.render()
