// Generated by CoffeeScript 1.8.0
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.TargetFractal = (function(_super) {
    __extends(_Class, _super);

    function _Class(target_fractal_manager) {
      Backbone.Model.apply(this);
      this.target_fractal_manager = target_fractal_manager;
    }

    return _Class;

  })(Backbone.Model);

  window.TargetFractalView = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.template = _.template("<div id='target-canvas'> <div class='target-mandelbrot' /> </div>");

    function _Class(options) {
      if (options == null) {
        options = {};
      }
      this.render = __bind(this.render, this);
      this.model = options.model, this.classname = options.classname;
      this.fractal_manager_view = new window.FractalManagerView(this.model.target_fractal_manager);
      Backbone.View.apply(this);
    }

    _Class.prototype.initialize = function() {
      this.$el = $('#target-fractal');
      this.render();
      this.model.on('change', this.render, this);
      return this.fractal_manager_view.initialize();
    };

    _Class.prototype.assign = function(view, selector) {
      view.setElement($(selector));
      return view.render();
    };

    _Class.prototype.render = function() {
      this.$el.html(this.template());
      return this.assign(this.fractal_manager_view, '.target-mandelbrot');
    };

    return _Class;

  })(Backbone.View);

}).call(this);
