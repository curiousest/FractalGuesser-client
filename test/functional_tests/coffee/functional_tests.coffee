webdriver = require 'selenium-webdriver'
assert = require 'assert'
should = require 'should'

describe('Peter plays the first level', ->

  driver = new webdriver.Builder().
     withCapabilities(webdriver.Capabilities.chrome()).
     build()

  # Peter hits the html page with the game in it
  driver.get('file:///home/dough/workspace/JSFractalGame/src/exampleUsage.html')

  # He sees two fractals, one an image with text indicating it's where he has to go
  driver.findElement(webdriver.By.id('target-fractal'))
  driver.findElement(webdriver.By.id('target-canvas'))
  target_zoom = driver.findElement(webdriver.By.id('target-zoom'))
  (target_zoom == null).should.not.be.ok
  target_zoom.text.should.containEql('x')

  # And the other fractal, a game with simple instructions
  driver.findElement(webdriver.By.id('fractal-game'))
  driver.findElement(webdriver.By.id('fractal-canvas'))
  instructions = driver.findElement(webdriver.By.id('fractal-game-instructions'))
  (instructions == null).should.not.be.ok
  instructions.text.should.containEql('Click to zoom')

  # He hovers his mouse over the game and sees a square appear
  # The square indicates what zoom he will be at when he clicks

  # He clicks and the game erases the previous fractal
  # And draws a new one zoomed in to where he clicked

  driver.quit();
)

