// Generated by CoffeeScript 1.8.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.FractalGame = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.API_CANVAS_RATIO = 400 / 285;

    _Class.prototype.ZOOM_MULTIPLIER = 4;

    _Class.prototype.target_route = [];

    _Class.prototype.travelled_route = [];

    _Class.prototype.clicks_remaining = 6;

    _Class.prototype.bonus_clicks = 0;

    _Class.prototype.may_play_next_round = false;

    _Class.prototype.round_over = false;

    _Class.prototype.target_fractal = 0;

    _Class.prototype.target_fractal_manager = 0;

    _Class.prototype.active_fractal_manager = 0;

    _Class.prototype.defaults = {
      zoom: 1,
      score: 0,
      round: 0,
      fractal_game_message: "Click to zoom in. Try to zoom in to the exact location of the fractal on the left."
    };

    function _Class(pixel_canvas_size, cartesian_canvas_size, cartesian_diagonal, fractalAlgorithm, colorPicker) {
      this.toggleVisibleFractal = __bind(this.toggleVisibleFractal, this);
      this.newRandomTargetCanvas = __bind(this.newRandomTargetCanvas, this);
      this.generateRoute = __bind(this.generateRoute, this);
      this.playNextRound = __bind(this.playNextRound, this);
      this.back = __bind(this.back, this);
      this.zoomIn = __bind(this.zoomIn, this);
      this.roundFinished = __bind(this.roundFinished, this);
      this.startGame = __bind(this.startGame, this);
      this.startRound = __bind(this.startRound, this);
      var target_fractal_manager;
      Backbone.Model.apply(this);
      this.cartesian_diagonal = cartesian_diagonal;
      if (pixel_canvas_size.width / pixel_canvas_size.height > this.API_CANVAS_RATIO) {
        this.active_canvas_pixel_height = pixel_canvas_size.height;
        this.active_canvas_pixel_width = Math.floor(pixel_canvas_size.height * this.API_CANVAS_RATIO);
      } else {
        this.active_canvas_pixel_width = pixel_canvas_size.width;
        this.active_canvas_pixel_height = Math.floor(pixel_canvas_size.width / this.API_CANVAS_RATIO);
      }
      this.target_canvas_pixel_width = this.active_canvas_pixel_width;
      this.target_canvas_pixel_height = this.active_canvas_pixel_height;
      this.active_fractal_manager = new window.FractalManager(cartesian_canvas_size, this.active_canvas_pixel_width, this.active_canvas_pixel_height, fractalAlgorithm, colorPicker);
      target_fractal_manager = new window.FractalManager(cartesian_canvas_size, this.target_canvas_pixel_width, this.target_canvas_pixel_height, fractalAlgorithm, colorPicker);
      this.target_fractal = new window.TargetFractal(target_fractal_manager);
    }

    _Class.prototype.startRound = function(this_round) {
      this.may_play_next_round = false;
      this.travelled_route = [];
      this.round_over = false;
      if (this_round == null) {
        this_round = this.get('round') + 1;
      }
      this.set('round', this_round);
      this.set('zoom', 1);
      this.clicks_remaining = 6 + this.bonus_clicks;
      this.active_fractal_manager.visible = false;
      this.target_fractal_manager.visible = true;
      this.active_fractal_manager.resetCanvas();
      if (this_round === 1) {
        this.set('fractal_game_message', "Instructions: switch between your target and current location.<br/>Click on your current canvas and try to zoom into the target.");
      } else {
        this.set('fractal_game_message', "Round " + this.get('round') + " in progress.");
      }
      $('#next-round-button').css('visibility', 'hidden');
      return this.newRandomTargetCanvas(this_round);
    };

    _Class.prototype.startGame = function() {
      this.set('round', 0);
      this.set('score', 0);
      this.bonus_clicks = 0;
      return this.startRound(1);
    };

    _Class.prototype.roundFinished = function(success) {
      var active_c, distance, round_score, target_c;
      this.round_over = true;
      if (success) {
        this.set('score', this.get('score') + 100 + this.clicks_remaining);
        this.set('fractal_game_message', "Perfect! Round " + this.get('round') + ": 100 / 100. Continue to next round.");
        this.bonus_clicks = this.clicks_remaining;
      } else {
        active_c = this.active_fractal_manager.getCenterCoordinate();
        target_c = this.target_fractal.target_fractal_manager.getCenterCoordinate();
        distance = Math.sqrt(Math.pow(active_c.x - target_c.x, 2) + Math.pow(active_c.y - target_c.y, 2));
        round_score = 100 - 100 * Math.abs((this.cartesian_diagonal - (9 * distance)) / this.cartesian_diagonal);
        this.set('fractal_game_message', "Round over. Round " + this.get('round') + ": " + round_score + " / 100");
        this.set('score', this.get('score') + round_score);
      }
      if (this.get('round') !== 3) {
        this.may_play_next_round = true;
        return $('#next-round-button').css('visibility', 'visible');
      } else {
        return this.set('fractal_game_message', this.get('fractal_game_message') + "<br/> Game finished. Total score : " + this.get('score') + "/300");
      }
    };

    _Class.prototype.zoomIn = function(picked_section) {
      var i, new_zoom, on_correct_route, _i, _ref;
      this.travelled_route.push(picked_section);
      new_zoom = this.get('zoom') * this.ZOOM_MULTIPLIER;
      this.active_fractal_manager.setCanvas(picked_section, new_zoom);
      this.set('zoom', new_zoom);
      if (this.may_play_next_round || this.round_over) {
        return;
      }
      this.clicks_remaining -= 1;
      on_correct_route = false;
      if (new_zoom === this.target_fractal.zoom) {
        on_correct_route = true;
        for (i = _i = 0, _ref = this.target_route.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (this.target_route[i].x !== this.travelled_route[i].x || this.target_route[i].y !== this.travelled_route[i].y) {
            on_correct_route = false;
          }
        }
        if (on_correct_route) {
          this.roundFinished(true);
        }
      }
      if (this.clicks_remaining === 0 && !on_correct_route) {
        return this.roundFinished(false);
      }
    };

    _Class.prototype.back = function() {
      if (this.get('zoom') === 1 || this.clicks_remaining === 0) {
        return;
      }
      this.active_fractal_manager.previousCanvas();
      this.travelled_route.pop();
      this.set('zoom', this.get('zoom') / this.ZOOM_MULTIPLIER);
      this.clicks_remaining -= 1;
      if (this.clicks_remaining === 0) {
        return this.roundFinished(false);
      }
    };

    _Class.prototype.playNextRound = function() {
      if (this.may_play_next_round) {
        return this.startRound(this.get('round') + 1);
      } else if (this.round_over) {
        return this.startGame();
      }
    };

    _Class.prototype.generateRoute = function(success_function, error_function) {
      var next_section;
      next_section = 0;
      return $.ajax({
        url: window.fractal_api_url + "generate/mandelbrot/",
        type: "GET",
        success: function(data) {
          return success_function(data);
        },
        failure: error_function
      });
    };

    _Class.prototype.newRandomTargetCanvas = function(next_round) {
      this.target_fractal.target_fractal_manager.resetCanvas();
      return this.generateRoute((function(_this) {
        return function(generated_route) {
          var round, section, _i, _len, _ref;
          _this.target_route = generated_route['route'];
          round = 0;
          _ref = _this.target_route;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            section = _ref[_i];
            round++;
            _this.target_fractal.target_fractal_manager.setCanvas(section, Math.pow(_this.ZOOM_MULTIPLIER, round));
          }
          _this.target_fractal.zoom = Math.pow(_this.ZOOM_MULTIPLIER, generated_route['level']);
          _this.target_fractal.trigger('change');
          return $('#target-fractal').css('visibility', 'visible');
        };
      })(this), function(failure_message) {
        return alert("Failed to reach fractal-generating server with error: " + failure_message);
      });
    };

    _Class.prototype.toggleVisibleFractal = function() {
      active_fractal_manager.toggleVisible();
      return target_fractal_manager.toggleVisible();
    };

    return _Class;

  })(Backbone.Model);

  window.FractalGameView = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.$canvas_el = 0;

    _Class.prototype.current_section = {
      x: 0,
      y: 0
    };

    _Class.prototype.template = _.template("<div class='fractal-menu'> <button id='toggle-target-fractal' class='btn fractal-game-btn'>Show/Hide Target</button> <button id='fractal-back-button' class='btn fractal-game-btn'>Back</button> <button id='next-round-button' class='btn btn-success fractal-game-btn'>Play Next round</button> </div> <div class='fractal-info'> <span id='clicks-remaining' class='fractal-game-text'>Clicks left: <%= clicks_remaining %></span> <br/> <span id='active-zoom' class='zoom fractal-game-text'>Zoom: x<%= zoom %></span> <br/> <span class='fractal-game-text' id='fractal-game-message'> <%= fractal_game_message %> </span> </div> <div id='active-canvas' style='position:relative;'> <div class='fractal-canvas-holder' /> <div class='fractal-sections' /> </div>");

    function _Class(options) {
      if (options == null) {
        options = {};
      }
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      this.model = options.model, this.classname = options.classname;
      this.fractal_sections = new window.FractalSections({
        width: this.model.active_canvas_pixel_width,
        height: this.model.active_canvas_pixel_height,
        on_click_function: this.model.zoomIn
      });
      this.fractal_sections_view = new window.FractalSectionsView(this.fractal_sections);
      this.active_fractal_manager_view = new window.FractalManagerView(this.model.active_fractal_manager);
      this.target_fractal_view = new window.TargetFractalView({
        model: this.model.target_fractal
      });
      Backbone.View.apply(this);
    }

    _Class.prototype.initialize = function() {
      this.$el = $('#active-fractal');
      this.model.on('change', this.render, this);
      this.render();
      this.fractal_sections_view.initialize();
      this.active_fractal_manager_view.initialize();
      return this.model.startGame();
    };

    _Class.prototype.assign = function(view, selector) {
      view.setElement($(selector));
      return view.render();
    };

    _Class.prototype.toggleVisibleFractal = function() {
      var active_fractal, target_fractal;
      target_fractal = $('#target-canvas');
      active_fractal = $('#active-canvas');
      if (target_fractal.css('visibility') === 'hidden') {
        target_fractal.css('visibility', 'visible');
        return active_fractal.css('visibility', 'hidden');
      } else {
        target_fractal.css('visibility', 'hidden');
        return active_fractal.css('visibility', 'visible');
      }
    };

    _Class.prototype.render = function() {
      this.$el.html(this.template({
        'zoom': this.model.get('zoom'),
        'clicks_remaining': this.model.clicks_remaining,
        'active_canvas_pixel_width': this.model.active_canvas_pixel_width,
        'active_canvas_pixel_height': this.model.active_canvas_pixel_height,
        'fractal_game_message': this.model.get('fractal_game_message')
      }));
      $('#toggle-target-fractal').on('click', this.toggleVisibleFractal);
      $('#next-round-button').on('click', this.model.playNextRound);
      $('#fractal-back-button').on('click', this.model.back);
      this.assign(this.active_fractal_manager_view, '.fractal-canvas-holder');
      return this.assign(this.fractal_sections_view, '.fractal-sections');
    };

    return _Class;

  })(Backbone.View);

}).call(this);
