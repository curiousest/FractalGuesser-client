window.TargetFractal = class extends Backbone.Model
  constructor: (@zoom, @coordinates) ->
  
  zoomIn: (zoomIncrease) ->
    @zoom = @zoom * zoomIncrease

target = new window.TargetFractal()
