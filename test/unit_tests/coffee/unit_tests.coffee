window.fractal_api_url = "http://localhost:8000/api/"
fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE )
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
  
  describe('generateRoute(level: int, success_function: ->, failure_function: ->)', ->
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
    it('should return an array at level 1 with a route that has an x/y value, ex: [{x:0,y:0}]', ->
      fractal_game.generateRoute(1, 
        (route)->
          route.length.should.eql(1)
          (route[0].x == null or route[0].y == null).should.not.be.true
      )
    )
    it('should return an array at level 2 with two routes that are each 5 characters long', ->
      fractal_game.generateRoute(2,
        (route)->
          route.length.should.eql(2)
          (route[0].x == null or route[0].y == null).should.not.be.true
          (route[1].x == null or route[1].y == null).should.not.be.true
      )
    )
  )
)

describe('FractalManager', ->  
  describe('FractalManager(canvas_size: {width: int, height: int}, top_left_default: {x: int, y: int}, bottom_right_default: {x: int, y: int})', ->
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
  describe('previousCanvas()', ->
    it('should return the default canvas when there`s no history left to undo', ->
      fractal_manager.resetCanvas()
      fractal_manager.previousCanvas()
      fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'))
      fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'))
    )
    it('should go back one canvas in history',->
      fractal_manager.resetCanvas()
      fractal_manager.setCanvas({x: 1, y: 1}, 4)
      fractal_manager.previousCanvas()
      fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'))
      fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'))
      
      fractal_manager.setCanvas({x: 1, y: 1}, 4)
      fractal_manager.setCanvas({x: 2, y: 2}, 16)
      fractal_manager.previousCanvas()
      fractal_manager.get('top_left').should.eql({x: -1.625, y: 0.625})
      fractal_manager.get('bottom_right').should.eql({x: -0.75, y: 0})
      fractal_manager.previousCanvas()
      fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'))
      fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'))
    )
  )
)
