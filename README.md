FractalGuesser-client
=====================
FractalGuesser is GeoGuessr for fractals. It's running live here: http://dmhindson.pythonanywhere.com.

Client
======
The client is built with Backbone.js in CoffeeScript. It uses this great Mandelbrot set renderer I forked: https://github.com/curiousest/mandelbrot-js.

Server
=====
The server is a really simple Django 1.7 web API used to hold the 10 000's of possible correct routes that can be chosen: https://github.com/curiousest/FractalGuesser-server.

Build
=====
Build the JavaScript from CoffeeScript with "cake build". 

Test
====
Client tests written with Should.js. Unit test the client by hitting ./test/unit_tests/unit_tests.html.
Server unit tests run like normal Django apps: "python manage.py test".
