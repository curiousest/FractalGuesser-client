window.fractal_api_url = "http://localhost:8000/api/"
fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL)
fractal_game_view = new window.FractalGameView({model:fractal_game})
fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285)
fractal_manager_view = new window.FractalManagerView({model:fractal_manager})

describe('FractalGame', ->

  describe('startRound(round: int)', ->
    it('should set the current zoom round to 1', ->
      fractal_game.startRound(1)
      fractal_game.get('zoom').should.be.exactly(1)
    )
    it('should set the current game`s round', ->
      fractal_game.startRound(2)
      fractal_game.get('round').should.be.exactly(2)
    )
    it('should set the clicks left counter to 6', ->
      fractal_game.startGame()
      fractal_game.clicks_remaining.should.be.exactly(6)
      fractal_game.startRound(3)
      fractal_game.clicks_remaining.should.be.exactly(6)
      fractal_game.startRound(2)
      fractal_game.clicks_remaining.should.be.exactly(6)
    )
  )
  
  describe('startGame()', ->
    it('should start at round 1 with 0 score', ->
      fractal_game.startGame()
      fractal_game.get('zoom').should.be.exactly(1)
      fractal_game.get('score').should.be.exactly(0)
    )
    it('should allow three rounds to be played when rounds succeed', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          for route in local_fractal_game.target_route
            local_fractal_game.zoomIn(route)
          local_fractal_game.may_play_next_round.should.be.true
          
          local_fractal_game.playNextRound()
          setTimeout( 
            =>
              for route in local_fractal_game.target_route
                local_fractal_game.zoomIn(route)
              local_fractal_game.may_play_next_round.should.be.true
            200
          )
        200
      )
    )
    it('should allow three rounds to be played when rounds fail', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          for route in local_fractal_game.target_route
            local_fractal_game.zoomIn(route)
          local_fractal_game.may_play_next_round.should.be.true
          
          local_fractal_game.playNextRound()
          setTimeout( 
            =>
              for route in local_fractal_game.target_route
                local_fractal_game.zoomIn(route)
              local_fractal_game.may_play_next_round.should.be.true
            200
          )
        200
      )
    )
    it('should end the game after three rounds are played', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          for i in [1..6]
            local_fractal_game.zoomIn({x: 1, y: 1})
          local_fractal_game.playNextRound()
          setTimeout( 
            =>
              for i in [1..6]
                local_fractal_game.zoomIn({x: 1, y: 1})
                
              local_fractal_game.playNextRound()
              setTimeout( 
                =>
                  for route in local_fractal_game.target_route
                    local_fractal_game.zoomIn(route)
                  local_fractal_game.may_play_next_round.should.be.false
                200
              )
            200
          )
        200
      )
    )
    it('should give a perfect score > (310) after three successful rounds', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          for route in local_fractal_game.target_route
            local_fractal_game.zoomIn(route)
          
          local_fractal_game.playNextRound()
          setTimeout( 
            =>
              for route in local_fractal_game.target_route
                local_fractal_game.zoomIn(route)
              local_fractal_game.playNextRound()
              setTimeout( 
                =>
                  for route in local_fractal_game.target_route
                    local_fractal_game.zoomIn(route)
                  local_fractal_game.get('score').should.be.greaterThan(310)
                200
              )
            200
          )
        200
      )
    )
    it('should give a score relative to the center coordinate distances between target and active fractal after each round', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout(
        =>
          for i in [1..6]
            local_fractal_game.zoomIn({x: 1, y: 1})
          local_fractal_game.playNextRound()
          setTimeout( 
            =>
              for i in [1..6]
                local_fractal_game.zoomIn({x: 1, y: 1})
              local_fractal_game.playNextRound()
              setTimeout( 
                =>
                  for i in [1..6]
                    local_fractal_game.zoomIn({x: 1, y: 1})
                  score = local_fractal_game.get('score')
                  score.should.be.greaterThan(-600)
                  score.should.be.lessThan(300)
                200
              )
            200
          )
        200
      )
    )
    it('should carry over extra clicks from previous rounds', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          initial_clicks = local_fractal_game.clicks_remaining
          for route in local_fractal_game.target_route
            local_fractal_game.zoomIn(route)
          local_fractal_game.may_play_next_round.should.be.true
          
          local_fractal_game.playNextRound()
          setTimeout( 
            =>
              initial_clicks.should.be.lessThan(local_fractal_game.clicks_remaining)
            200
          )
        200
      )
    )
  )
  
  describe('generateRoute(success_function: ->, failure_function: ->)', ->
    it('should return an array at at least length 1 with a route that has an x/y value, ex: [{x:0,y:0}]', ->
      fractal_game.generateRoute(
        (route)->
          route['route'].length.should.not.eql(0)
          (route['route'][0].x == null or route['route'][0].y == null).should.not.be.true
      )
    )
  )
  
  describe('back()', ->
    it('should zoom the canvas out zoom_multiplier times', ->
      fractal_game.startGame()
      fractal_game.startRound(2)
      fractal_game.zoomIn({x: 1, y: 1})
      fractal_game.back()
      fractal_game.get('zoom').should.be.exactly(1)
    )
    it('should not change anything if already at the top-most round', ->
      fractal_game.startGame()
      clicks_remaining = fractal_game.clicks_remaining
      fractal_game.back()
      fractal_game.get('zoom').should.be.exactly(1)
      fractal_game.clicks_remaining.should.be.exactly(clicks_remaining)
    )
    it('should decrement the clicks remaining counter', ->
      # local fractal game needed so timeouts don't conflict with other test cases
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      # timeouts are to allow the server to respond to route generation requests on local_fractal_game.startRound() calls
      setTimeout( 
        =>
          local_fractal_game.zoomIn({x: 1, y: 1})
          clicks_remaining = local_fractal_game.clicks_remaining
          local_fractal_game.back()
          local_fractal_game.clicks_remaining.should.be.exactly(clicks_remaining - 1)
        100
      )
    )
    it('should not change clicks_remaining if there are no clicks remaining', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          while(local_fractal_game.clicks_remaining > 0)
            local_fractal_game.zoomIn({x: 1, y: 1})
          zoom = local_fractal_game.get('zoom')
          local_fractal_game.back()
          local_fractal_game.clicks_remaining.should.be.exactly(0)
        200
      )
    )
    it('shouldn`t prevent the user from reaching the correct route', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout(
        => 
          local_fractal_game.zoomIn({x: 0, y: 0})
          local_fractal_game.back()
          for route in local_fractal_game.target_route
            local_fractal_game.zoomIn(route)
          local_fractal_game.round_over.should.be.true
        200
      )
    )
    it('should end the round if the clicks remaining counter decrements to zero', ->
      local_fractal_game = new window.FractalGame({width: 400, height: 285}, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL )
      local_fractal_game.startGame()
      setTimeout( 
        =>
          for i in [1..5]
            local_fractal_game.zoomIn({x: 1, y: 1})
          local_fractal_game.back()
          local_fractal_game.round_over.should.be.true
        200
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
  describe('getCenterCoordinate()', ->
    it('should return {-0.75, 0} at the base Mandelbrot canvas size', ->
      fractal_manager.resetCanvas()
      c = fractal_manager.getCenterCoordinate()
      c.x.should.eql(-0.75)
      c.y.should.eql(0)
    )
    it('should return {-2.0625, 0.9375} after zooming into section {x:0,y:0} on Mandelbrot canvas size', ->
      fractal_manager.resetCanvas()
      fractal_manager.setCanvas({x: 0, y: 0}, 4)
      c = fractal_manager.getCenterCoordinate()
      c.x.should.eql(-2.0625)
      c.y.should.eql(0.9375)
    )
  )
)
