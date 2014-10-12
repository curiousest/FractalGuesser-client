active_fractal = new window.ActiveFractal(MANDELBROT_CANVAS_SIZE)
active_fractal_view = new window.ActiveFractalView({model:active_fractal})
target_fractal = new window.TargetFractal(MANDELBROT_CANVAS_SIZE, active_fractal)
target_fractal_view = new window.TargetFractalView({model:target_fractal})
fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285)

describe('TargetFractal', ->
  describe('newRandomCanvas(level: int)', ->
    it('should set the fractal manager`s top left and bottom right coordinates appropriately distant at level 1', ->
      target_fractal.newRandomCanvas(1)
      top_left = target_fractal.fractal_manager.get('top_left')
      bottom_right = target_fractal.fractal_manager.get('bottom_right')
      (bottom_right.x - top_left.x).should.eql(0.875)
      (top_left.y - bottom_right.y).should.eql(0.625)
    )
    it('should set the fractal manager`s top left and bottom right coordinates appropriately distant at level 2', ->
      target_fractal.newRandomCanvas(2)
      top_left = target_fractal.fractal_manager.get('top_left')
      bottom_right = target_fractal.fractal_manager.get('bottom_right')
      (bottom_right.x - top_left.x).should.eql(0.21875)
      (top_left.y - bottom_right.y).should.eql(0.15625)
    )
    it('should set the fractal manager`s top left and bottom right coordinates appropriately distant at level 6', ->
      target_fractal.newRandomCanvas(6)
      top_left = target_fractal.fractal_manager.get('top_left')
      bottom_right = target_fractal.fractal_manager.get('bottom_right')
      (bottom_right.x - top_left.x).should.eql(0.0008544921875)
      (top_left.y - bottom_right.y).should.eql(0.0006103515625)
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

  describe('zoomIn(new_top_left)', ->
    it('should zoom in to current zoom * zoom multiplier', ->
      active_fractal.zoomIn({x: 0, y: 0})
      active_fractal.get('zoom').should.be.exactly(4)
      active_fractal.zoomIn({x: 0, y: 0})
      active_fractal.get('zoom').should.be.exactly(16)
    )
    it('should update the canvas coordinates for the active fractal`s fractal manager', ->
      active_fractal.startGame()
      active_fractal.zoomIn({x: 0.5, y: 0.5})
      active_fractal.fractal_manager.get('bottom_right').should.eql({x: -1.620625, y: 0.6206140350877194})
    )
  )
)

describe('TargetFractalView (with mandelbrot 400 x 285 canvas size and 4x4 sections)', ->

  describe('getCanvasSection(coordinate: {x:int, y:int})', ->
    it('should return the top-left section for {0,0}', ->
      target_fractal.getCanvasSection({x:0, y:0}).should.eql({x:0, y:0})
    )
    it('should return the bottom-left section for {399, 284}', ->
      target_fractal.getCanvasSection({x:399, y:284}).should.eql({x:3, y:3})
    )
    it('should return the appropriate section for {250, 250}', ->
      target_fractal.getCanvasSection({x:250, y:250}).should.eql({x:2, y:3})
    )
  )
  describe('getCanvasSectionCoordinates(section: {x:int, y:int})', ->
    it('should return the coordinates for the top left section at {0,0}', ->
      target_fractal.getCanvasSectionCoordinates({x:0,y:0}).should.eql({top_left: {x:0, y:0}, bottom_right:{x:100, y:72}})
    )
    it('should return the bottom-left section for {3, 3}', ->
      target_fractal.getCanvasSectionCoordinates({x:3,y:3}).should.eql({top_left: {x:300, y:214}, bottom_right:{x:400, y:285}})
    )
    it('should return the appropriate section for {2, 3}', ->
      target_fractal.getCanvasSectionCoordinates({x:2,y:3}).should.eql({top_left: {x:200, y:214}, bottom_right:{x:300, y:285}})
    )
  )
)

describe('FractalManager', ->  
  describe('FractalManager(top_left_default: {x: int, y: int}, bottom_right_default: {x: int, y: int})', ->
    it('should set the initial top left and bottom right values', ->
      fractal_manager.get('top_left').should.eql({x: -2.5, y: 1.25})
      fractal_manager.get('bottom_right').should.eql({x: 1, y: -1.25})
    )
    it('should calculate the width and height of the entire canvas', ->
      fractal_manager.get('entire_width').should.eql(3.5)
      fractal_manager.get('entire_height').should.eql(2.5)
    )
  )
  describe('setCanvas(top_left: {x: int, y: int}, zoom: int, old_zoom: int)', ->
    it('should update the fractal`s top_left coordinate', ->
      fractal_manager.setCanvas({x: 100, y: 71.25}, 4, 1)
      fractal_manager.get('top_left').should.eql({x: -1.625, y: 0.625})
    )
    it('should calculate and update the fractal`s bottom_right coordinate', ->
      fractal_manager.setCanvas({x: 100, y: 71.25}, 4, 1)
      fractal_manager.get('bottom_right').should.eql({x: 0.125, y: -0.625})
      fractal_manager.setCanvas({x: 100, y: 71.25}, 16, 4)
      fractal_manager.get('bottom_right').should.eql({x: -0.3125, y: -0.3125})
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
)
