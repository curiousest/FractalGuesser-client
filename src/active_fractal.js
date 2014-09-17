// Generated by CoffeeScript 1.8.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.ActiveFractal = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.defaults = {
      zoom: 1,
      level: 1,
      max_zoom: 4,
      zoom_multiplier: 4,
      fractal_manager: 0
    };

    function _Class(canvas_size) {
      this.startGame = __bind(this.startGame, this);
      this.startLevel = __bind(this.startLevel, this);
      Backbone.Model.apply(this);
      this.fractal_manager = new window.FractalManager(canvas_size);
    }

    _Class.prototype.startLevel = function(this_level) {
      this.fractal_manager.resetCanvas();
      this.set('level', this_level);
      this.set('zoom', 1);
      return this.set('max_zoom', Math.pow(this.get('zoom_multiplier'), this_level));
    };

    _Class.prototype.startGame = function() {
      return this.startLevel(1);
    };

    _Class.prototype.zoomIn = function(new_top_left) {
      this.set('zoom', this.get('zoom') * this.get('zoom_multiplier'));
      return this.fractal_manager.setCanvas(new_top_left, this.get('zoom'));
    };

    return _Class;

  })(Backbone.Model);

  window.ActiveFractalView = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.template = _.template("<div id='instructions'> Click to zoom in. Try to zoom in to the exact location of the fractal on the left. </div> <div class='canvas-header'> Current Level: <%= level %> clicks deep Zoom at target location: x<%= max_zoom %> </div> <div id='active-canvas'> <canvas id='canvasMandelbrot' width='600' height='500'> </canvas> <div id='active-zoom' class='zoom'><%= zoom %>x</div> </div>");

    function _Class(options) {
      if (options == null) {
        options = {};
      }
      this.render = __bind(this.render, this);
      this.model = options.model, this.classname = options.classname;
      this.$el = $('#active-fractal');
      this.render();
    }

    _Class.prototype.initialize = function() {
      return this.model.on('change', this.render, this);
    };

    _Class.prototype.render = function() {
      this.$el.html(this.template({
        'zoom': this.model.get('zoom'),
        'level': this.model.get('level'),
        'max_zoom': this.model.get('max_zoom')
      }));
      return draw($('#canvasMandelbrot')[0], [-2, 1], [-1.5, 1.5], pickColorHSV1, mandelbrotAlgorithm);
    };

    return _Class;

  })(Backbone.View);

}).call(this);
