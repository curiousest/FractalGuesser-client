target_fractal = new window.TargetFractal()
active_fractal = new window.ActiveFractal()

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
  
  fractal_manager = new window.FractalManager({x: -2, y: 1}, {x: 1.5, y: -1.5})
  
  describe('FractalManager(top_left_default: {x: int, y: int}, bottom_right_default: {x: int, y: int})', ->
    it('should set the initial top left and bottom right values', ->
      fractal_manager.get('top_left').should.eql({x: -2, y: 1})
      fractal_manager.get('bottom_right').should.eql({x: 1.5, y: -1.5})
    )
    it('should calculate the width and height of the entire canvas', ->
      fractal_manager.get('entire_width').should.eql(3.5)
      fractal_manager.get('entire_height').should.eql(2.5)
    )
  )
  describe('setCanvas(top_left: {x: int, y: int}, zoom: int)', ->
    it('should update the fractal`s top_left coordinate', ->
      fractal_manager.setCanvas({x: 0.5, y: 0.5}, 4)
      fractal_manager.get('top_left').should.eql({x: 0.5, y: 0.5})
    )
    it('should calculate and update the fractal`s bottom_right coordinate', ->
      fractal_manager.setCanvas({x: 0.5, y: 0.5}, 4)
      fractal_manager.get('bottom_right').should.eql({x: 1.375, y: -0.125})
      fractal_manager.setCanvas({x: 0.6, y: 0.5}, 8)
      fractal_manager.get('bottom_right').should.eql({x: 1.0375, y: 0.1875})
    )
  )
  describe('resetCanvas()', ->
    it('should set the top left and bottom right coordinates back to their default values', ->
      fractal_manager.setCanvas({x: 0.5, y: 0.5}, 4)
      fractal_manager.resetCanvas()
      fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'))
      fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'))
    )
  )
  describe('renderCanvas()', ->
  
  )
)
