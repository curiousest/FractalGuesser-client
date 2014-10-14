fractal_game = new window.FractalGame(MANDELBROT_CANVAS_SIZE)
fractal_game_view = new window.FractalGameView({model:fractal_game})
fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285)

describe('FractalGame', ->

  describe('startLevel(level: int)', ->
    it('should set the current zoom level to 1', ->
      fractal_game.startLevel(1)
      fractal_game.get('zoom').should.be.exactly(1)
    )
    it('should set the current game`s level', ->
      fractal_game.startLevel(2)
      fractal_game.get('level').should.be.exactly(2)
    )
    it('should set the maximum zoom for this game`s level', ->
      fractal_game.startLevel(1)
      fractal_game.get('max_zoom').should.be.exactly(4)
    )
  )
  
  describe('startGame()', ->
    it('should set the game`s level to 1', ->
      fractal_game.startGame()
      fractal_game.get('level').should.be.exactly(1)
    )
    it('should start at level 1', ->
      fractal_game.startGame()
      fractal_game.get('zoom').should.be.exactly(1)
      fractal_game.get('max_zoom').should.be.exactly(4)
    )
  )

  describe('zoomIn(next_section)', ->
    it('should zoom in to current zoom * zoom multiplier', ->
      fractal_game.startLevel(2)
      fractal_game.zoomIn({x: 0, y: 0})
      fractal_game.get('zoom').should.be.exactly(4)
      fractal_game.zoomIn({x: 0, y: 0})
      fractal_game.get('zoom').should.be.exactly(16)
    )
    it('should update the canvas coordinates for the active fractal`s fractal manager', ->
      fractal_game.startGame()
      fractal_game.zoomIn({x: 1, y: 1})
      fractal_game.active_fractal_manager.get('bottom_right').should.eql({x: 1, y: -1.25})
    )
  )
  
  describe('generateRoute(level: int)', ->
    it('should reject unreasonable levels', ->
      error = 0
      try
        route = fractal_game(-1)
      catch error
      error.should.not.eql(0)
      
      error = 0
      try
        route = fractal_game(50)
      catch error
      error.should.not.eql(0)
    ) 
    it('should return a route at level 1 that isn`t in the bad routes list', ->
      route = fractal_game.generateRoute(1)
      section = route.pop()
      window.bad_routes[section.x][section.y].should.not.be.false
    )
    it('should return a route at level 2 that isn`t in the bad routes list', ->
      route = fractal_game.generateRoute(2)
      current_bad_route = window.bad_routes
      while (route.length > 0)
        section = route.pop()
        current_bad_routes = current_bad_routes[section.x][section.y]
        current_bad_routes.should.not.be.false
    )
    it('should return a route at level 5 that isn`t in the bad routes list', ->
      route = fractal_game.generateRoute(5)
      current_bad_route = window.bad_routes
      while (route.length > 0)
        section = route.pop()
        current_bad_routes = current_bad_routes[section.x][section.y]
        current_bad_routes.should.not.be.false
    )
  )
  
  describe('newRandomCanvas(level: int)', ->
    it('should set the target fractal manager`s top left and bottom right coordinates appropriately distant at level 1', ->
      fractal_game.newRandomTargetCanvas(1)
      top_left = fractal_game.target_fractal.target_fractal_manager.get('top_left')
      bottom_right = fractal_game.target_fractal.target_fractal_manager.get('bottom_right')
      (bottom_right.x - top_left.x).should.eql(0.875)
      (top_left.y - bottom_right.y).should.eql(0.625)
    )
    it('should set the target fractal manager`s top left and bottom right coordinates appropriately distant at level 2', ->
      fractal_game.newRandomTargetCanvas(2)
      top_left = fractal_game.target_fractal.target_fractal_manager.get('top_left')
      bottom_right = fractal_game.target_fractal.target_fractal_manager.get('bottom_right')
      (bottom_right.x - top_left.x).should.eql(0.21875)
      (top_left.y - bottom_right.y).should.eql(0.15625)
    )
    it('should set the target fractal manager`s top left and bottom right coordinates appropriately distant at level 6', ->
      fractal_game.newRandomTargetCanvas(6)
      top_left = fractal_game.target_fractal.target_fractal_manager.get('top_left')
      bottom_right = fractal_game.target_fractal.target_fractal_manager.get('bottom_right')
      (bottom_right.x - top_left.x).should.eql(0.0008544921875)
      (top_left.y - bottom_right.y).should.eql(0.0006103515625)
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
  describe('resetCanvas()', ->
    it('should set the top left and bottom right coordinates back to their default values', ->
      fractal_manager.setCanvas({x: 0.5, y: 0.5}, 4)
      fractal_manager.resetCanvas()
      fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'))
      fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'))
    )
  )
  describe('setCanvas(target_section: {x: int, y: int}, zoom: int, old_zoom: int)', ->
    it('should update the fractal`s top_left coordinate', ->
      fractal_manager.setCanvas({x: 1, y: 1}, 4)
      fractal_manager.get('top_left').should.eql({x: -1.625, y: 0.625})
      fractal_manager.resetCanvas()
      fractal_manager.setCanvas({x: 3, y: 0}, 4)
      fractal_manager.get('top_left').should.eql({x: 0.125, y: 1.25})
    )
    it('should calculate and update the fractal`s bottom_right coordinate', ->
      fractal_manager.resetCanvas()
      fractal_manager.setCanvas({x: 1, y: 1}, 4)
      fractal_manager.get('bottom_right').should.eql({x: -0.75, y: 0})
      fractal_manager.setCanvas({x: 1, y: 1}, 16)
      fractal_manager.get('bottom_right').should.eql({x: -1.1875, y: 0.3125})
    )
  )
)
