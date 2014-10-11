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

task 'watch', 'Watch coffee directories for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'test/unit_tests/coffee', 'test/unit_tests']
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'src/coffee', 'src']
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'test/functional_tests/coffee', 'test/functional_tests']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'minify', 'Minify the resulting application file after build', ->
  exec 'java -jar "/home/dough/public/compiler.jar" --js src/app.js --js_output_file src/app.production.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    
task 'functional_tests', 'Run the selenium webdriver tests in the file functional_tests.js in test/functional_tests', ->
  exec 'node test/functional_tests/functional_tests.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    
task 'unit_tests', 'Run the mocha tests in the file unit_tests.html in test/unit_tests', ->
  exec 'mocha-phantomjs test/unit_tests/unit_tests.html', (err, stdout, stderr) ->
    if err
      exec 'google-chrome --console test/unit_tests/unit_tests.html'
    console.log stdout + stderr
