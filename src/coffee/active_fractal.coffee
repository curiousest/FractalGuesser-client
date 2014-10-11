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
    @el.classList.add('fractal-section')
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
  sectionList: []

  constructor: (@collection) ->
    Backbone.View.apply(@)  
  
  initialize: =>
    @collection.forEach(
      (section) =>
        @sectionList.push(new window.FractalSectionView({model: section}))
    )
  
  render: =>
    @$el.append(section.render()) for section in @sectionList
    return @$el

window.ActiveFractal = class extends Backbone.Model
  SECTION_ROW_COUNT: 4
  SECTION_COLUMN_COUNT: 4
  CANVAS_PIXEL_WIDTH: 400
  CANVAS_PIXEL_HEIGHT: 285
  defaults:
    zoom: 1
    level: 1
    max_zoom: 4
    zoom_multiplier: 4
    
  constructor: (canvas_size) ->
    Backbone.Model.apply(@)
    @fractal_manager = new window.FractalManager(canvas_size, @CANVAS_PIXEL_WIDTH, @CANVAS_PIXEL_HEIGHT)
    
  startLevel: (this_level) =>
    @fractal_manager.resetCanvas()
    @set 'level', this_level
    @set 'zoom', 1
    @set 'max_zoom', Math.pow(@get('zoom_multiplier'), this_level)
    
  endLevel: =>
    console.log('complete me')
    
  startGame: =>
    @startLevel(1)
  
  zoomIn: (new_top_left) =>
    new_zoom = @get('zoom') * @get('zoom_multiplier')
    @fractal_manager.setCanvas(new_top_left, new_zoom, @get('zoom'))
    if (new_zoom >= @get('max_zoom'))
      @endLevel()
    @set 'zoom', new_zoom

window.ActiveFractalView = class extends Backbone.View
  
  $canvas_el: 0
  current_section: {x:0, y:0}
  
  template: _.template(
    "<div id='fractal-game-message'>
      Click to zoom in. Try to zoom in to the exact location of the fractal on the left.
    </div>
    <div class='canvas-header'>
      Current zoom: <span id='active-zoom' class='zoom'>x<%= zoom %></span> 
      <br/>
      Target zoom: <span id='target-zoom' class='zoom'>x<%= max_zoom %></span>
      <br/>
      Clicks remaining: <span id='remaining-clicks'><%= remaining_clicks %></span>
    </div>
    <div id='active-canvas' style='position:relative;'>
        <div class='active-mandelbrot' />
        <div class='fractal-sections' />

    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
 
    @fractal_sections = new window.FractalSections({
      width: @model.CANVAS_PIXEL_WIDTH
      height: @model.CANVAS_PIXEL_HEIGHT
      on_click_function: @model.zoomIn
    })
    @fractal_sections_view = new window.FractalSectionsView(@fractal_sections)
    @fractal_manager_view = new window.FractalManagerView(@model.fractal_manager)
    
    Backbone.View.apply(@)
    
  initialize: =>
    @$el = $ '#active-fractal'
    @model.on('change', @render, @)
    @render()
    
    @fractal_sections_view.initialize()
    @fractal_manager_view.initialize()
    
  assign: (view, selector) -> 
    view.setElement($(selector))
    view.render()
    
  render: =>
    @$el.html(@template({
      'zoom':@model.get('zoom')
      'max_zoom': @model.get('max_zoom')
      'remaining_clicks': @model.get('max_zoom')/@model.get('zoom_multiplier') - Math.floor(@model.get('zoom')/@model.get('zoom_multiplier'))
      'CANVAS_PIXEL_WIDTH': @model.CANVAS_PIXEL_WIDTH
      'CANVAS_PIXEL_HEIGHT': @model.CANVAS_PIXEL_HEIGHT
    }))
    
    @assign(@fractal_manager_view, '.active-mandelbrot')
    @assign(@fractal_sections_view, '.fractal-sections')

