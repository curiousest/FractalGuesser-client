target_fractal = new window.TargetFractal()

describe('TargetFractal', ->
  describe('#zoomIn()', ->
    it('should zoom in to 2 when initially zoomed in 2', ->
      target_fractal.zoomIn(2)
      target_fractal.get('zoom').should.be(2)
    )
  )
)



