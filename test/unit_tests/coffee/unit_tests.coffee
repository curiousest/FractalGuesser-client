target_fractal = new window.TargetFractal(MANDELBROT_CANVAS_SIZE)
active_fractal = new window.ActiveFractal(MANDELBROT_CANVAS_SIZE)
active_fractal_view = new window.ActiveFractalView({model:active_fractal})
fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE)

describe('TargetFractal', ->
  describe('zoomTo(top_left: {x,y}, zoom: int)', ->
    it('should set the fractal`s top_left coordinate', ->
      target_fractal.zoomTo({x: 1, y: 1}, 4)
      target_fractal.fractal_manager.get('top_left').should.eql({x: 1, y: 1})
    )
    it('should set the fractal`s bottom_left coordinate', ->
      target_fractal.zoomTo({x: 0.5, y: 0.5}, 4)
      target_fractal.fractal_manager.get('bottom_right').should.eql({x: 1.375, y: -0.125})
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
      active_fractal.fractal_manager.get('bottom_right').should.eql({x: 1.375, y: -0.125})
    )
  )
)

describe('ActiveFractalView (with mandelbrot canvas size and 4x4 sections)', ->

  describe('getCanvasSection(coordinate: {x:int, y:int})', ->
    it('should return the top-left section for {0,0}', ->
      active_fractal_view.getCanvasSection({x:0, y:0}).should.eql({x:0, y:0})
    )
    it('should return the bottom-left section for {399, 399}', ->
      active_fractal_view.getCanvasSection({x:399, y:399}).should.eql({x:3, y:3})
    )
    it('should return the appropriate section for {250, 350}', ->
      active_fractal_view.getCanvasSection({x:250, y:350}).should.eql({x:2, y:3})
    )
  )
  describe('getCanvasSectionCoordinates(section: {x:int, y:int})', ->
    it('should return the coordinates for the top left section at {0,0}', ->
      active_fractal_view.getCanvasSectionCoordinates({x:0,y:0}).should.eql({top_left: {x:0, y:0}, bottom_right:{x:100, y:100}})
    )
    it('should return the bottom-left section for {3, 3}', ->
      active_fractal_view.getCanvasSectionCoordinates({x:3,y:3}).should.eql({top_left: {x:300, y:300}, bottom_right:{x:400, y:400}})
    )
    it('should return the appropriate section for {2, 3}', ->
      active_fractal_view.getCanvasSectionCoordinates({x:2,y:3}).should.eql({top_left: {x:200, y:300}, bottom_right:{x:300, y:400}})
    )
  )
)

describe('FractalManager', ->  
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
)
