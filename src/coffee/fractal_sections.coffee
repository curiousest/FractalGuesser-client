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

