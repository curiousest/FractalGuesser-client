// Generated by CoffeeScript 1.8.0
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.FractalSection = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.top_left = {
      x: 0,
      y: 0
    };

    _Class.prototype.section = {
      x: 0,
      y: 0
    };

    _Class.prototype.width = 0;

    _Class.prototype.height = 0;

    _Class.prototype.on_click_function = 0;

    function _Class(options) {
      if (options == null) {
        options = {};
      }
      Backbone.Model.apply(this);
      this.top_left = options.top_left, this.section = options.section, this.width = options.width, this.height = options.height, this.on_click_function = options.on_click_function;
    }

    return _Class;

  })(Backbone.Model);

  window.FractalSectionView = (function(_super) {
    __extends(_Class, _super);

    function _Class() {
      this.destroy = __bind(this.destroy, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      _Class.__super__.constructor.apply(this, arguments);
      this.el.classList.add('fractal-section');
      this.el.setAttribute('style', 'top: ' + this.model.top_left.y + 'px; ' + 'left: ' + this.model.top_left.x + 'px; ' + 'min-width: ' + this.model.width + 'px; ' + 'min-height: ' + this.model.height + 'px; ');
      this.$el.html('&nbsp');
    }

    _Class.prototype.initialize = function() {
      return this.$el.on('click', (function(_this) {
        return function(e) {
          if (e.timeStamp === _this.last_click_time_stamp) {
            return;
          }
          _this.last_click_time_stamp = e.timeStamp;
          return _this.model.on_click_function(_this.model.section);
        };
      })(this));
    };

    _Class.prototype.render = function() {
      return this.$el;
    };

    _Class.prototype.destroy = function() {
      this.remove();
      return this.$el.off('click', null, this);
    };

    return _Class;

  })(Backbone.View);

  window.FractalSections = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.model = window.FractalSection;

    _Class.prototype.sections = 4;

    _Class.prototype.width = 0;

    _Class.prototype.height = 0;

    function _Class(options) {
      var fractalSection, section_height, section_width, top_left, x_offset, y_offset, _i, _j, _ref, _ref1;
      _Class.__super__.constructor.apply(this, arguments);
      this.pop();
      this.width = options.width, this.height = options.height;
      for (x_offset = _i = 0, _ref = this.sections - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x_offset = 0 <= _ref ? ++_i : --_i) {
        section_width = this.width / this.sections;
        for (y_offset = _j = 0, _ref1 = this.sections - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y_offset = 0 <= _ref1 ? ++_j : --_j) {
          section_height = this.height / this.sections;
          top_left = {
            x: Math.floor(x_offset * section_width),
            y: Math.floor(y_offset * section_height)
          };
          fractalSection = new window.FractalSection({
            top_left: top_left,
            section: {
              x: x_offset,
              y: y_offset
            },
            width: Math.floor(section_width) - 1,
            height: Math.floor(section_height) - 1,
            on_click_function: options.on_click_function
          });
          this.add(fractalSection);
        }
      }
    }

    return _Class;

  })(Backbone.Collection);

  window.FractalSectionsView = (function(_super) {
    __extends(_Class, _super);

    _Class.prototype.sectionList = [];

    function _Class(collection) {
      this.collection = collection;
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      Backbone.View.apply(this);
    }

    _Class.prototype.initialize = function() {
      return this.collection.forEach((function(_this) {
        return function(section) {
          return _this.sectionList.push(new window.FractalSectionView({
            model: section
          }));
        };
      })(this));
    };

    _Class.prototype.render = function() {
      var section, _i, _len, _ref;
      _ref = this.sectionList;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        section = _ref[_i];
        this.$el.append(section.render());
        section.initialize();
      }
      return this.$el;
    };

    return _Class;

  })(Backbone.View);

}).call(this);
