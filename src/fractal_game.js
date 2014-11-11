// Generated by CoffeeScript 1.8.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.FractalGame = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.SECTION_ROW_COUNT = 4;

    _Class.prototype.SECTION_COLUMN_COUNT = 4;

    _Class.prototype.CANVAS_PIXEL_WIDTH = 400;

    _Class.prototype.CANVAS_PIXEL_HEIGHT = 285;

    _Class.prototype.zoom_multiplier = 4;

    _Class.prototype.target_order = [];

    _Class.prototype.on_correct_route = true;

    _Class.prototype.defaults = {
      zoom: 1,
      level: 1,
      max_zoom: 4,
      fractal_game_message: "Click to zoom in. Try to zoom in to the exact location of the fractal on the left."
    };

    function _Class(canvas_size) {
      this.newRandomTargetCanvas = __bind(this.newRandomTargetCanvas, this);
      this.generateRoute = __bind(this.generateRoute, this);
      this.zoomIn = __bind(this.zoomIn, this);
      this.startGame = __bind(this.startGame, this);
      this.endLevel = __bind(this.endLevel, this);
      this.startLevel = __bind(this.startLevel, this);
      var target_fractal_manager;
      Backbone.Model.apply(this);
      this.x_section_size = this.CANVAS_PIXEL_WIDTH / this.SECTION_COLUMN_COUNT;
      this.y_section_size = this.CANVAS_PIXEL_HEIGHT / this.SECTION_ROW_COUNT;
      this.active_fractal_manager = new window.FractalManager(canvas_size, this.CANVAS_PIXEL_WIDTH, this.CANVAS_PIXEL_HEIGHT);
      target_fractal_manager = new window.FractalManager(canvas_size, this.CANVAS_PIXEL_WIDTH, this.CANVAS_PIXEL_HEIGHT);
      this.target_fractal = new window.TargetFractal(target_fractal_manager);
    }

    _Class.prototype.startLevel = function(this_level) {
      this.newRandomTargetCanvas(this_level);
      this.active_fractal_manager.resetCanvas();
      this.set('level', this_level);
      this.set('zoom', 1);
      return this.set('max_zoom', Math.pow(this.zoom_multiplier, this_level));
    };

    _Class.prototype.endLevel = function() {
      if (this.on_correct_route) {
        return this.startLevel(this.get('level') + 1);
      } else {
        return this.set('fractal_game_message', "Incorrect choice. Sorry, you picked the wrong route. Refresh to try again...or keep zooming in...");
      }
    };

    _Class.prototype.startGame = function() {
      return this.startLevel(1);
    };

    _Class.prototype.zoomIn = function(picked_section) {
      var correct_section, new_zoom;
      if (this.zoom_lock) {
        return;
      }
      this.zoom_lock = true;
      new_zoom = this.get('zoom') * this.zoom_multiplier;
      this.active_fractal_manager.setCanvas(picked_section, new_zoom);
      this.set('zoom', new_zoom);
      correct_section = this.target_order.shift();
      if (!(correct_section.x === picked_section.x && correct_section.y === picked_section.y)) {
        this.on_correct_route = false;
      }
      if (new_zoom === this.get('max_zoom')) {
        return setTimeout((function(_this) {
          return function() {
            _this.endLevel();
            return _this.zoom_lock = false;
          };
        })(this), 1000);
      } else {
        return this.zoom_lock = false;
      }
    };

    _Class.prototype.generateRoute = function(next_level) {
      var level, next_section, remaining_bad_routes, route, _i;
      if (next_level < 0 || next_level > 20) {
        throw new error("Tried to generate route with invalid level.");
      }
      route = [];
      remaining_bad_routes = window.bad_routes;
      next_section = 0;
      for (level = _i = 1; 1 <= next_level ? _i <= next_level : _i >= next_level; level = 1 <= next_level ? ++_i : --_i) {
        next_section = 0;
        while (!(next_section !== 0)) {
          next_section = {
            x: Math.floor(Math.random() * 4),
            y: Math.floor(Math.random() * 4)
          };
          if (level > window.bad_routes.max_depth) {
            break;
          }
          if (remaining_bad_routes[next_section.x] && remaining_bad_routes[next_section.x][next_section.y] && !$.isEmptyObject(remaining_bad_routes[next_section.x][next_section.y])) {
            remaining_bad_routes = remaining_bad_routes[next_section.x][next_section.y];
          } else {
            next_section = 0;
          }
        }
        this.target_fractal.target_fractal_manager.setCanvas(next_section, Math.pow(this.zoom_multiplier, level));
        route.push(next_section);
      }
      return route;
    };

    _Class.prototype.newRandomTargetCanvas = function(next_level) {
      this.target_fractal.target_fractal_manager.resetCanvas();
      this.target_order = this.generateRoute(next_level);
      return this.target_fractal.trigger('change');
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

    _Class.prototype.template = _.template("<div id='fractal-game-message'> <%= fractal_game_message %> </div> <div class='canvas-header'> Current zoom: <span id='active-zoom' class='zoom'>x<%= zoom %></span> <br/> Target zoom: <span id='target-zoom' class='zoom'>x<%= max_zoom %></span> <br/> Clicks remaining: <span id='remaining-clicks'><%= remaining_clicks %></span> </div> <div id='active-canvas' style='position:relative;'> <div class='active-mandelbrot' /> <div class='fractal-sections' /> </div>");

    function _Class(options) {
      if (options == null) {
        options = {};
      }
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      this.model = options.model, this.classname = options.classname;
      this.fractal_sections = new window.FractalSections({
        width: this.model.CANVAS_PIXEL_WIDTH,
        height: this.model.CANVAS_PIXEL_HEIGHT,
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
      this.model.newRandomTargetCanvas(1);
      return this.target_fractal_view.initialize();
    };

    _Class.prototype.assign = function(view, selector) {
      view.setElement($(selector));
      return view.render();
    };

    _Class.prototype.render = function() {
      this.$el.html(this.template({
        'zoom': this.model.get('zoom'),
        'max_zoom': this.model.get('max_zoom'),
        'remaining_clicks': this.model.get('max_zoom') / this.model.zoom_multiplier - Math.floor(this.model.get('zoom') / this.model.zoom_multiplier),
        'CANVAS_PIXEL_WIDTH': this.model.CANVAS_PIXEL_WIDTH,
        'CANVAS_PIXEL_HEIGHT': this.model.CANVAS_PIXEL_HEIGHT,
        'fractal_game_message': this.model.get('fractal_game_message')
      }));
      this.assign(this.active_fractal_manager_view, '.active-mandelbrot');
      return this.assign(this.fractal_sections_view, '.fractal-sections');
    };

    return _Class;

  })(Backbone.View);

}).call(this);
