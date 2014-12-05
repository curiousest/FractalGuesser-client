window.TargetFractal = class extends Backbone.Model

  constructor: (target_fractal_manager) ->
    Backbone.Model.apply(@)
    @target_fractal_manager = target_fractal_manager
    @zoom = 1
  
window.TargetFractalView = class extends Backbone.View
  template: _.template("
    <div id='target-canvas'>
        <div class='target-mandelbrot' />
    </div>")

  constructor: (options={}) ->
    {@model, @classname} = options
    
    @fractal_manager_view = new window.FractalManagerView(@model.target_fractal_manager)
    
    Backbone.View.apply(@)
    
  initialize: ->
    @$el = $ '#target-fractal'
    @render()
    @model.on('change', @render, @)
    @fractal_manager_view.initialize()
    
  assign: (view, selector) -> 
    view.setElement($(selector))
    view.render()
  
  # this view is only needed to link the canvas to this element without having to get rendered repeatedly
  render: =>
    @$el.html(@template({}))
    @assign(@fractal_manager_view, '.target-mandelbrot')
