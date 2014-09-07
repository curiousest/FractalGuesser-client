{exec} = require 'child_process'
task 'build', 'Build all project coffee files from coffee/*.coffee to *.js', ->
  exec 'coffee --compile --output src/ src/coffee/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
  exec 'coffee --compile --output test/unit_tests/ test/unit_tests/coffee/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
  exec 'coffee --compile --output test/functional_tests/ test/functional_tests/coffee/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
task 'minify', 'Minify the resulting application file after build', ->
  exec 'java -jar "/home/dough/public/compiler.jar" --js src/app.js --js_output_file src/app.production.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
task 'functional_tests', 'Run the selenium webdriver tests in the file functional_tests.js in test/functional_tests', ->
  exec 'mocha test/functional_tests/functional_tests.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
task 'unit_tests', 'Run the mocha tests in the file unit_tests.js in test/unit_tests', ->
  exec 'mocha test/unit_tests/unit_tests.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
