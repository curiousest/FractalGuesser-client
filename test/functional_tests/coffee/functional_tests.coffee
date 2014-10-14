webdriver = require 'selenium-webdriver'
assert = require 'assert'
should = require 'should'

functional_tests = {}
functional_tests.peter_plays_first_level = ->

  driver = new webdriver.Builder().
     withCapabilities(webdriver.Capabilities.chrome()).
     build()
     
  timer = new webdriver.promise.ControlFlow()

  # Peter hits the html page with the game in it
  driver.get('file:///home/dough/workspace/JSFractalGame/test/exampleUsage.html')

  # He sees two fractals, one an image without gridlines
  driver.findElement(webdriver.By.id('target-fractal'))
  target_canvas = driver.findElement(webdriver.By.className('target-mandelbrot'))
  (target_canvas.getAttribute("width") == 0).should.not.be.true

  # And the other, with gridlines indicating sections
  active_canvas = driver.findElement(webdriver.By.className('active-mandelbrot'))
  (active_canvas.getAttribute("width") == 0).should.not.be.true
  
  fractal_sections = driver.findElement(webdriver.By.className('fractal-sections'))
  first_fractal_section = fractal_sections.findElement(webdriver.By.className('fractal-section'))
  (first_fractal_section == null).should.not.be.true
  
  # He sees the current zoom of the active fractal, the zoom of the target fractal, and the number of clicks remaining
  active_zoom = driver.findElement(webdriver.By.id('active-zoom'))
  active_zoom.getAttribute('innerHTML').then((result)->
    'x1'.should.equal(result)
  )
  
  target_zoom = driver.findElement(webdriver.By.id('target-zoom'))
  target_zoom.getAttribute('innerHTML').then((result)->
    'x4'.should.equal(result)
  )
  
  remaining_clicks = driver.findElement(webdriver.By.id('remaining-clicks'))
  remaining_clicks.getAttribute('innerHTML').then((result)->
    '1'.should.equal(result)
  )

  # He clicks on the top left squre of the active fractal, and the fractal zooms in to that square 
  # The current zoom and number of clicks remaining changes
  # He is notified that he picked the incorrect square
  
  first_fractal_section.click()
  active_zoom = driver.findElement(webdriver.By.id('active-zoom'))
  active_zoom.getAttribute('innerHTML').then((result)->
    'x4'.should.equal(result)
  )
  remaining_clicks = driver.findElement(webdriver.By.id('remaining-clicks'))
  remaining_clicks.getAttribute('innerHTML').then((result)->
    '0'.should.equal(result)
  )
  
  message = driver.findElement(webdriver.By.id('fractal-game-message'))
  message.getAttribute('innerHTML').then((result)->
    result.should.containEql('Incorrect')
  )
  
  # He clicks on the restart button to restart the game
  # He clicks on the correct fractal section to zoom into
  # He is notified that he picked the correct square
  
  restart_button = driver.findElement(webdriver.By.id('restart-fractal-game-button'))
  restart_button.click()
  
  fractal_sections = driver.findElement(webdriver.By.className('fractal-sections'))
  correct_fractal_section = fractal_sections.findElements(webdriver.By.className('fractal-section'))[7]
  #correct_fractal_section.click()
  console.log(correct_fractal_section)
  
  message = driver.findElement(webdriver.By.id('fractal-game-message'))
  message.getAttribute('innerHTML').then((result)->
    result.should.containEql('Correct')
  )

  driver.quit()


functional_tests.peter_plays_first_level()

