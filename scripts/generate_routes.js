// Generated by CoffeeScript 1.8.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.RouteGenerator = (function() {
    var dummy_canvas, fractal_manager, has_colored_pixel, pixels_checked, routes;

    fractal_manager = null;

    dummy_canvas = null;

    routes = null;

    pixels_checked = 0;

    has_colored_pixel = false;

    function _Class() {
      this.insertRoutes = __bind(this.insertRoutes, this);
      this.checkRoutes = __bind(this.checkRoutes, this);
      this.pickColorHSV1_CheckColor = __bind(this.pickColorHSV1_CheckColor, this);
      var canvas_attribute;
      this.max_depth = 3;
      this.fractal_manager = new window.FractalManager(MANDELBROT_CANVAS_SIZE, 400, 285);
      this.routes = {
        max_depth: this.max_depth
      };
      this.dummy_canvas = document.createElement('canvas');
      canvas_attribute = document.createAttribute("width");
      canvas_attribute.value = "400";
      this.dummy_canvas.setAttributeNode(canvas_attribute);
      canvas_attribute = document.createAttribute("height");
      canvas_attribute.value = "285";
      this.dummy_canvas.setAttributeNode(canvas_attribute);
    }

    _Class.prototype.pickColorHSV1_CheckColor = function(steps, n, Tr, Ti) {
      var c, v;
      this.pixels_checked = this.pixels_checked + 1;
      if (n === steps) {
        return interiorColor;
      }
      v = smoothColor(steps, n, Tr, Ti);
      c = hsv_to_rgb(360.0 * v / steps, 1.0, 1.0);
      if (c[0] !== 255 || c[2] !== 0) {
        this.has_colored_pixel = true;
      }
      c.push(255);
      return c;
    };

    _Class.prototype.checkRoutes = function(current_route, depth) {
      var x_section, y_section, _i, _results;
      if (depth > this.max_depth) {
        return;
      }
      this.pixels_checked = 0;
      this.has_colored_pixel = false;
      draw(this.dummy_canvas, {
        x: this.fractal_manager.get('top_left').x,
        y: this.fractal_manager.get('bottom_right').x
      }, {
        x: this.fractal_manager.get('top_left').y,
        y: this.fractal_manager.get('bottom_right').y
      }, this.pickColorHSV1_CheckColor, mandelbrotAlgorithm);
      if (!this.has_colored_pixel) {
        return;
      }
      _results = [];
      for (x_section = _i = 0; _i <= 3; x_section = ++_i) {
        current_route[x_section] = {};
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (y_section = _j = 0; _j <= 3; y_section = ++_j) {
            current_route[x_section][y_section] = {};
            this.fractal_manager.setCanvas({
              x: x_section,
              y: y_section
            }, Math.pow(4, depth + 1));
            this.checkRoutes(current_route[x_section][y_section], depth + 1);
            _results1.push(this.fractal_manager.previousCanvas());
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    _Class.prototype.insertRoutes = function(server_url) {
      var current_level, current_route, new_route, route_id, route_queue, x_section, y_section, _results;
      route_queue = [];
      route_queue.push({
        level: 0,
        route: '[',
        remaining_routes: this.routes
      });
      route_id = -1;
      current_level = 0;
      _results = [];
      while (route_queue.length > 0) {
        current_route = route_queue.shift();
        route_id++;
        if (current_route.level !== current_level) {
          current_level++;
          console.log("Level " + current_level + " begins at id=" + route_id);
        }
        $.ajax({
          url: server_url,
          type: "POST",
          crossDomain: true,
          data: {
            level: current_route.level,
            route: current_route.route + ']',
            route_id: route_id
          },
          dataType: "json"
        });
        if (current_route.level === this.max_depth) {
          continue;
        }
        _results.push((function() {
          var _i, _results1;
          _results1 = [];
          for (x_section = _i = 0; _i <= 3; x_section = ++_i) {
            _results1.push((function() {
              var _j, _results2;
              _results2 = [];
              for (y_section = _j = 0; _j <= 3; y_section = ++_j) {
                if (current_route.remaining_routes[x_section] && current_route.remaining_routes[x_section][y_section] && !$.isEmptyObject(current_route.remaining_routes[x_section][y_section])) {
                  new_route = {
                    level: current_route.level + 1,
                    route: current_route.route,
                    remaining_routes: current_route.remaining_routes[x_section][y_section]
                  };
                  if (new_route.route.length !== 1) {
                    new_route.route = new_route.route + ',';
                  }
                  new_route.route = new_route.route + '{' + x_section + ',' + y_section + '}';
                  _results2.push(route_queue.push(new_route));
                } else {
                  _results2.push(void 0);
                }
              }
              return _results2;
            })());
          }
          return _results1;
        })());
      }
      return _results;
    };

    return _Class;

  })();

  $(document).ready(function() {
    var csrftoken, route_generator;
    route_generator = new window.RouteGenerator;
    route_generator.checkRoutes(route_generator.routes, 0);
    csrftoken = $.cookie('csrftoken');
    $.ajaxSetup({
      beforeSend: function(xhr, settings) {
        return xhr.setRequestHeader("X-CSRFToken", csrftoken);
      }
    });
    return route_generator.insertRoutes('http://localhost:8000/api/insert/');
  });

}).call(this);
