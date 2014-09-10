target_fractal = new window.TargetFractal()
active_fractal = new window.ActiveFractal()
fractal_manager = new window.FractalManager()

describe('TargetFractal', ->
  describe('zoomIn(zoom_multiplier: int)', ->
    it('should zoom in to current zoom * zoom multiplier', ->
      target_fractal.zoomIn(2)
      target_fractal.get('zoom').should.be.exactly(2)
      target_fractal.zoomIn(4)
      target_fractal.get('zoom').should.be.exactly(8)
    )
  )
)

describe('ActiveFractal', ->

  describe('startLevel(level: int)', ->
    it('should set the current zoom level to 1', ->
      active_fractal.startLevel(1)
      active_fractal.get('zoom').should.be.exactly(1)
    )
    it('should set the current game`s level', ->
      active_fractal.startLevel(2)
      active_fractal.get('level').should.be.exactly(2)
    )
    it('should set the maximum zoom for this game`s level', ->
      active_fractal.startLevel(1)
      active_fractal.get('max_zoom').should.be.exactly(4)
    )
  )
  
  describe('startGame()', ->
    it('should set the game`s level to 1', ->
      active_fractal.startGame()
      active_fractal.get('level').should.be.exactly(1)
    )
    it('should start at level 1', ->
      active_fractal.startGame()
      active_fractal.get('zoom').should.be.exactly(1)
      active_fractal.get('max_zoom').should.be.exactly(4)
    )
  )
)

describe('FractalManager', ->
  describe('setCanvas(top_left: {x: int, y: int}, zoom: int)', ->
    it('should update the fractal`s top_left coordinate', ->
      fractal_manager.setCanvas({x: 0.5, y: 0.5}, 4)
      fractal_manager.get('top_left').should.eql({x: 0.5, y: 0.5})
    )
    it('should calculate and update the fractal`s bottom_right coordinate', ->
      fractal_manager.setCanvas({x: 0.5, y: 0.5}, 4)
      fractal_manager.get('bottom_right').should.eql({x: 0.75, y: 0.25})
      fractal_manager.setCanvas({x: 0.6, y: 0.5}, 8)
      fractal_manager.get('bottom_right').should.eql({x: 0.725, y: 0.375})
    )
  )
  describe('renderCanvas()', ->
  
  )
)
