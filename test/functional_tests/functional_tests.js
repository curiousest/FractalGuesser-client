// Generated by CoffeeScript 1.8.0
(function() {
  var assert, functional_tests, should, webdriver;

  webdriver = require('selenium-webdriver');

  assert = require('assert');

  should = require('should');

  functional_tests = {};

  functional_tests.peter_plays_first_level = function() {
    var active_canvas, active_zoom, correct_fractal_section, driver, first_fractal_section, fractal_sections, message, remaining_clicks, restart_button, target_canvas, target_zoom, timer;
    driver = new webdriver.Builder().withCapabilities(webdriver.Capabilities.chrome()).build();
    timer = new webdriver.promise.ControlFlow();
    driver.get('file:///home/dough/workspace/JSFractalGame/test/exampleUsage.html');
    driver.findElement(webdriver.By.id('target-fractal'));
    target_canvas = driver.findElement(webdriver.By.className('target-mandelbrot'));
    (target_canvas.getAttribute("width") === 0).should.not.be["true"];
    active_canvas = driver.findElement(webdriver.By.className('active-mandelbrot'));
    (active_canvas.getAttribute("width") === 0).should.not.be["true"];
    fractal_sections = driver.findElement(webdriver.By.className('fractal-sections'));
    first_fractal_section = fractal_sections.findElement(webdriver.By.className('fractal-section'));
    (first_fractal_section === null).should.not.be["true"];
    active_zoom = driver.findElement(webdriver.By.id('active-zoom'));
    active_zoom.getAttribute('innerHTML').then(function(result) {
      return 'x1'.should.equal(result);
    });
    target_zoom = driver.findElement(webdriver.By.id('target-zoom'));
    target_zoom.getAttribute('innerHTML').then(function(result) {
      return 'x4'.should.equal(result);
    });
    remaining_clicks = driver.findElement(webdriver.By.id('remaining-clicks'));
    remaining_clicks.getAttribute('innerHTML').then(function(result) {
      return '1'.should.equal(result);
    });
    first_fractal_section.click();
    active_zoom = driver.findElement(webdriver.By.id('active-zoom'));
    active_zoom.getAttribute('innerHTML').then(function(result) {
      return 'x4'.should.equal(result);
    });
    remaining_clicks = driver.findElement(webdriver.By.id('remaining-clicks'));
    remaining_clicks.getAttribute('innerHTML').then(function(result) {
      return '0'.should.equal(result);
    });
    message = driver.findElement(webdriver.By.id('fractal-game-message'));
    message.getAttribute('innerHTML').then(function(result) {
      return result.should.containEql('Incorrect');
    });
    restart_button = driver.findElement(webdriver.By.id('restart-fractal-game-button'));
    restart_button.click();
    fractal_sections = driver.findElement(webdriver.By.className('fractal-sections'));
    correct_fractal_section = fractal_sections.findElements(webdriver.By.className('fractal-section'))[7];
    console.log(correct_fractal_section);
    message = driver.findElement(webdriver.By.id('fractal-game-message'));
    message.getAttribute('innerHTML').then(function(result) {
      return result.should.containEql('Correct');
    });
    return driver.quit();
  };

  functional_tests.peter_plays_first_level();

}).call(this);
