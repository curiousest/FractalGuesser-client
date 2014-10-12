// Generated by CoffeeScript 1.8.0
(function() {
  var fractal_game, fractal_game_view, fractal_manager;

  fractal_game = new window.FractalGame(MANDELBROT_CANVAS_SIZE);

  fractal_game_view = new window.FractalGameView({
    model: fractal_game
  });

  fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285);

  describe('FractalGame', function() {
    describe('startLevel(level: int)', function() {
      it('should set the current zoom level to 1', function() {
        fractal_game.startLevel(1);
        return fractal_game.get('zoom').should.be.exactly(1);
      });
      it('should set the current game`s level', function() {
        fractal_game.startLevel(2);
        return fractal_game.get('level').should.be.exactly(2);
      });
      return it('should set the maximum zoom for this game`s level', function() {
        fractal_game.startLevel(1);
        return fractal_game.get('max_zoom').should.be.exactly(4);
      });
    });
    describe('startGame()', function() {
      it('should set the game`s level to 1', function() {
        fractal_game.startGame();
        return fractal_game.get('level').should.be.exactly(1);
      });
      return it('should start at level 1', function() {
        fractal_game.startGame();
        fractal_game.get('zoom').should.be.exactly(1);
        return fractal_game.get('max_zoom').should.be.exactly(4);
      });
    });
    describe('zoomIn(next_section)', function() {
      it('should zoom in to current zoom * zoom multiplier', function() {
        fractal_game.startLevel(2);
        fractal_game.zoomIn({
          x: 0,
          y: 0
        });
        fractal_game.get('zoom').should.be.exactly(4);
        fractal_game.zoomIn({
          x: 0,
          y: 0
        });
        return fractal_game.get('zoom').should.be.exactly(16);
      });
      return it('should update the canvas coordinates for the active fractal`s fractal manager', function() {
        fractal_game.startGame();
        fractal_game.zoomIn({
          x: 1,
          y: 1
        });
        return fractal_game.active_fractal_manager.get('bottom_right').should.eql({
          x: -0.75,
          y: 0
        });
      });
    });
    return describe('newRandomCanvas(level: int)', function() {
      it('should set the fractal manager`s top left and bottom right coordinates appropriately distant at level 1', function() {
        var bottom_right, top_left;
        fractal_game.newRandomTargetCanvas(1);
        top_left = fractal_game.target_fractal.target_fractal_manager.get('top_left');
        bottom_right = fractal_game.target_fractal.target_fractal_manager.get('bottom_right');
        (bottom_right.x - top_left.x).should.eql(0.875);
        return (top_left.y - bottom_right.y).should.eql(0.625);
      });
      it('should set the fractal manager`s top left and bottom right coordinates appropriately distant at level 2', function() {
        var bottom_right, top_left;
        fractal_game.newRandomTargetCanvas(2);
        top_left = fractal_game.target_fractal.target_fractal_manager.get('top_left');
        bottom_right = fractal_game.target_fractal.target_fractal_manager.get('bottom_right');
        (bottom_right.x - top_left.x).should.eql(0.21875);
        return (top_left.y - bottom_right.y).should.eql(0.15625);
      });
      return it('should set the fractal manager`s top left and bottom right coordinates appropriately distant at level 6', function() {
        var bottom_right, top_left;
        fractal_game.newRandomTargetCanvas(6);
        top_left = fractal_game.target_fractal.target_fractal_manager.get('top_left');
        bottom_right = fractal_game.target_fractal.target_fractal_manager.get('bottom_right');
        (bottom_right.x - top_left.x).should.eql(0.0008544921875);
        return (top_left.y - bottom_right.y).should.eql(0.0006103515625);
      });
    });
  });

  describe('FractalManager', function() {
    describe('FractalManager(top_left_default: {x: int, y: int}, bottom_right_default: {x: int, y: int})', function() {
      it('should set the initial top left and bottom right values', function() {
        fractal_manager.get('top_left').should.eql({
          x: -2.5,
          y: 1.25
        });
        return fractal_manager.get('bottom_right').should.eql({
          x: 1,
          y: -1.25
        });
      });
      return it('should calculate the width and height of the entire canvas', function() {
        fractal_manager.get('entire_width').should.eql(3.5);
        return fractal_manager.get('entire_height').should.eql(2.5);
      });
    });
    describe('resetCanvas()', function() {
      return it('should set the top left and bottom right coordinates back to their default values', function() {
        fractal_manager.setCanvas({
          x: 0.5,
          y: 0.5
        }, 4);
        fractal_manager.resetCanvas();
        fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'));
        return fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'));
      });
    });
    return describe('setCanvas(target_section: {x: int, y: int}, zoom: int, old_zoom: int)', function() {
      it('should update the fractal`s top_left coordinate', function() {
        fractal_manager.setCanvas({
          x: 1,
          y: 1
        }, 4);
        fractal_manager.get('top_left').should.eql({
          x: -1.625,
          y: 0.625
        });
        fractal_manager.resetCanvas();
        fractal_manager.setCanvas({
          x: 3,
          y: 0
        }, 4);
        return fractal_manager.get('top_left').should.eql({
          x: 0.125,
          y: 1.25
        });
      });
      return it('should calculate and update the fractal`s bottom_right coordinate', function() {
        fractal_manager.resetCanvas();
        fractal_manager.setCanvas({
          x: 1,
          y: 1
        }, 4);
        fractal_manager.get('bottom_right').should.eql({
          x: -0.75,
          y: 0
        });
        fractal_manager.setCanvas({
          x: 1,
          y: 1
        }, 16);
        return fractal_manager.get('bottom_right').should.eql({
          x: -1.1875,
          y: 0.3125
        });
      });
    });
  });

}).call(this);
