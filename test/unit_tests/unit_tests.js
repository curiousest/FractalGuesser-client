// Generated by CoffeeScript 1.8.0
(function() {
  var fractal_game, fractal_game_view, fractal_manager, fractal_manager_view;

  window.fractal_api_url = "http://localhost:8000/api/";

  fractal_game = new window.FractalGame({
    width: 400,
    height: 285
  }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);

  fractal_game_view = new window.FractalGameView({
    model: fractal_game
  });

  fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285);

  fractal_manager_view = new window.FractalManagerView({
    model: fractal_manager
  });

  describe('FractalGame', function() {
    describe('startRound(round: int)', function() {
      it('should set the current zoom round to 1', function() {
        fractal_game.startRound(1);
        return fractal_game.get('zoom').should.be.exactly(1);
      });
      it('should set the current game`s round', function() {
        fractal_game.startRound(2);
        return fractal_game.get('round').should.be.exactly(2);
      });
      return it('should set the clicks left counter to 6', function() {
        fractal_game.startGame();
        fractal_game.clicks_remaining.should.be.exactly(6);
        fractal_game.startRound(3);
        fractal_game.clicks_remaining.should.be.exactly(6);
        fractal_game.startRound(2);
        return fractal_game.clicks_remaining.should.be.exactly(6);
      });
    });
    describe('startGame()', function() {
      it('should start at round 1 with 0 score', function() {
        fractal_game.startGame();
        fractal_game.get('zoom').should.be.exactly(1);
        return fractal_game.get('score').should.be.exactly(0);
      });
      it('should allow three rounds to be played when rounds succeed', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var route, _i, _len, _ref;
            _ref = local_fractal_game.target_route;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              route = _ref[_i];
              local_fractal_game.zoomIn(route);
            }
            local_fractal_game.may_play_next_round.should.be["true"];
            local_fractal_game.playNextRound();
            return setTimeout(function() {
              var _j, _len1, _ref1;
              _ref1 = local_fractal_game.target_route;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                route = _ref1[_j];
                local_fractal_game.zoomIn(route);
              }
              return local_fractal_game.may_play_next_round.should.be["true"];
            }, 200);
          };
        })(this), 200);
      });
      it('should allow three rounds to be played when rounds fail', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var route, _i, _len, _ref;
            _ref = local_fractal_game.target_route;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              route = _ref[_i];
              local_fractal_game.zoomIn(route);
            }
            local_fractal_game.may_play_next_round.should.be["true"];
            local_fractal_game.playNextRound();
            return setTimeout(function() {
              var _j, _len1, _ref1;
              _ref1 = local_fractal_game.target_route;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                route = _ref1[_j];
                local_fractal_game.zoomIn(route);
              }
              return local_fractal_game.may_play_next_round.should.be["true"];
            }, 200);
          };
        })(this), 200);
      });
      it('should end the game after three rounds are played', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var i, _i;
            for (i = _i = 1; _i <= 6; i = ++_i) {
              local_fractal_game.zoomIn({
                x: 1,
                y: 1
              });
            }
            local_fractal_game.playNextRound();
            return setTimeout(function() {
              var _j;
              for (i = _j = 1; _j <= 6; i = ++_j) {
                local_fractal_game.zoomIn({
                  x: 1,
                  y: 1
                });
              }
              local_fractal_game.playNextRound();
              return setTimeout(function() {
                var route, _k, _len, _ref;
                _ref = local_fractal_game.target_route;
                for (_k = 0, _len = _ref.length; _k < _len; _k++) {
                  route = _ref[_k];
                  local_fractal_game.zoomIn(route);
                }
                return local_fractal_game.may_play_next_round.should.be["false"];
              }, 200);
            }, 200);
          };
        })(this), 200);
      });
      it('should give a perfect score > (310) after three successful rounds', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var route, _i, _len, _ref;
            _ref = local_fractal_game.target_route;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              route = _ref[_i];
              local_fractal_game.zoomIn(route);
            }
            local_fractal_game.playNextRound();
            return setTimeout(function() {
              var _j, _len1, _ref1;
              _ref1 = local_fractal_game.target_route;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                route = _ref1[_j];
                local_fractal_game.zoomIn(route);
              }
              local_fractal_game.playNextRound();
              return setTimeout(function() {
                var _k, _len2, _ref2;
                _ref2 = local_fractal_game.target_route;
                for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                  route = _ref2[_k];
                  local_fractal_game.zoomIn(route);
                }
                return local_fractal_game.get('score').should.be.greaterThan(310);
              }, 200);
            }, 200);
          };
        })(this), 200);
      });
      it('should give a score relative to the center coordinate distances between target and active fractal after each round', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var i, _i;
            for (i = _i = 1; _i <= 6; i = ++_i) {
              local_fractal_game.zoomIn({
                x: 1,
                y: 1
              });
            }
            local_fractal_game.playNextRound();
            return setTimeout(function() {
              var _j;
              for (i = _j = 1; _j <= 6; i = ++_j) {
                local_fractal_game.zoomIn({
                  x: 1,
                  y: 1
                });
              }
              local_fractal_game.playNextRound();
              return setTimeout(function() {
                var score, _k;
                for (i = _k = 1; _k <= 6; i = ++_k) {
                  local_fractal_game.zoomIn({
                    x: 1,
                    y: 1
                  });
                }
                score = local_fractal_game.get('score');
                score.should.be.greaterThan(-600);
                return score.should.be.lessThan(300);
              }, 200);
            }, 200);
          };
        })(this), 200);
      });
      return it('should carry over extra clicks from previous rounds', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var initial_clicks, route, _i, _len, _ref;
            initial_clicks = local_fractal_game.clicks_remaining;
            _ref = local_fractal_game.target_route;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              route = _ref[_i];
              local_fractal_game.zoomIn(route);
            }
            local_fractal_game.may_play_next_round.should.be["true"];
            local_fractal_game.playNextRound();
            return setTimeout(function() {
              return initial_clicks.should.be.lessThan(local_fractal_game.clicks_remaining);
            }, 200);
          };
        })(this), 200);
      });
    });
    describe('generateRoute(success_function: ->, failure_function: ->)', function() {
      return it('should return an array at at least length 1 with a route that has an x/y value, ex: [{x:0,y:0}]', function() {
        return fractal_game.generateRoute(function(route) {
          route['route'].length.should.not.eql(0);
          return (route['route'][0].x === null || route['route'][0].y === null).should.not.be["true"];
        });
      });
    });
    return describe('back()', function() {
      it('should zoom the canvas out zoom_multiplier times', function() {
        fractal_game.startGame();
        fractal_game.startRound(2);
        fractal_game.zoomIn({
          x: 1,
          y: 1
        });
        fractal_game.back();
        return fractal_game.get('zoom').should.be.exactly(1);
      });
      it('should not change anything if already at the top-most round', function() {
        var clicks_remaining;
        fractal_game.startGame();
        clicks_remaining = fractal_game.clicks_remaining;
        fractal_game.back();
        fractal_game.get('zoom').should.be.exactly(1);
        return fractal_game.clicks_remaining.should.be.exactly(clicks_remaining);
      });
      it('should decrement the clicks remaining counter', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var clicks_remaining;
            local_fractal_game.zoomIn({
              x: 1,
              y: 1
            });
            clicks_remaining = local_fractal_game.clicks_remaining;
            local_fractal_game.back();
            return local_fractal_game.clicks_remaining.should.be.exactly(clicks_remaining - 1);
          };
        })(this), 100);
      });
      it('should not change clicks_remaining if there are no clicks remaining', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var zoom;
            while (local_fractal_game.clicks_remaining > 0) {
              local_fractal_game.zoomIn({
                x: 1,
                y: 1
              });
            }
            zoom = local_fractal_game.get('zoom');
            local_fractal_game.back();
            return local_fractal_game.clicks_remaining.should.be.exactly(0);
          };
        })(this), 200);
      });
      it('shouldn`t prevent the user from reaching the correct route', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var route, _i, _len, _ref;
            local_fractal_game.zoomIn({
              x: 0,
              y: 0
            });
            local_fractal_game.back();
            _ref = local_fractal_game.target_route;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              route = _ref[_i];
              local_fractal_game.zoomIn(route);
            }
            return local_fractal_game.round_over.should.be["true"];
          };
        })(this), 200);
      });
      return it('should end the round if the clicks remaining counter decrements to zero', function() {
        var local_fractal_game;
        local_fractal_game = new window.FractalGame({
          width: 400,
          height: 285
        }, MANDELBROT_CANVAS_SIZE, MANDELBROT_CANVAS_DIAGONAL);
        local_fractal_game.startGame();
        return setTimeout((function(_this) {
          return function() {
            var i, _i;
            for (i = _i = 1; _i <= 5; i = ++_i) {
              local_fractal_game.zoomIn({
                x: 1,
                y: 1
              });
            }
            local_fractal_game.back();
            return local_fractal_game.round_over.should.be["true"];
          };
        })(this), 200);
      });
    });
  });

  describe('FractalManager', function() {
    describe('FractalManager(canvas_size: {width: int, height: int}, top_left_default: {x: int, y: int}, bottom_right_default: {x: int, y: int})', function() {
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
    describe('setCanvas(target_section: {x: int, y: int}, zoom: int, old_zoom: int)', function() {
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
    describe('previousCanvas()', function() {
      it('should return the default canvas when there`s no history left to undo', function() {
        fractal_manager.resetCanvas();
        fractal_manager.previousCanvas();
        fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'));
        return fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'));
      });
      return it('should go back one canvas in history', function() {
        fractal_manager.resetCanvas();
        fractal_manager.setCanvas({
          x: 1,
          y: 1
        }, 4);
        fractal_manager.previousCanvas();
        fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'));
        fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'));
        fractal_manager.setCanvas({
          x: 1,
          y: 1
        }, 4);
        fractal_manager.setCanvas({
          x: 2,
          y: 2
        }, 16);
        fractal_manager.previousCanvas();
        fractal_manager.get('top_left').should.eql({
          x: -1.625,
          y: 0.625
        });
        fractal_manager.get('bottom_right').should.eql({
          x: -0.75,
          y: 0
        });
        fractal_manager.previousCanvas();
        fractal_manager.get('top_left').should.eql(fractal_manager.get('default_top_left'));
        return fractal_manager.get('bottom_right').should.eql(fractal_manager.get('default_bottom_right'));
      });
    });
    return describe('getCenterCoordinate()', function() {
      it('should return {-0.75, 0} at the base Mandelbrot canvas size', function() {
        var c;
        fractal_manager.resetCanvas();
        c = fractal_manager.getCenterCoordinate();
        c.x.should.eql(-0.75);
        return c.y.should.eql(0);
      });
      return it('should return {-2.0625, 0.9375} after zooming into section {x:0,y:0} on Mandelbrot canvas size', function() {
        var c;
        fractal_manager.resetCanvas();
        fractal_manager.setCanvas({
          x: 0,
          y: 0
        }, 4);
        c = fractal_manager.getCenterCoordinate();
        c.x.should.eql(-2.0625);
        return c.y.should.eql(0.9375);
      });
    });
  });

}).call(this);
