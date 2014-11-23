webgl
=====

the Coffeescript versions of the WebGL Programming Guide examples, refactored.

<canvas id='gl'
            style='width:400px; height:300px;
                   border: solid 1px black;' />
    <script src="http://code.jquery.com/jquery-2.1.1.min.js"></script>
    <script src="http://coffeescript.org/extras/coffee-script.js"></script>
    <script type="text/coffeescript">
      $ =>
        canvas = document.getElementById('gl')
        gl = canvas.getContext('experimental-webgl');
        gl.clearColor(0.0,0.0,0.0,1.0)
        gl.clear(gl.COLOR_BUFFER_BIT)
    </script>
