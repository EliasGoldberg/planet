$ ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('webgl')
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute float a_PointSize;
      uniform mat4 u_ModelMatrix;
      void main() {
        gl_Position = u_ModelMatrix * a_Position;
        gl_PointSize = a_PointSize;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
      }
    ''')

  program.activate()

  program.setAttribPointer('a_Position',[0.0, 0.3, -0.3, -0.3, 0.3, -0.3], 2)
  n = program.setAttribPointer('a_PointSize',[10.0, 20.0, 30.0], 1)

  gl.clearColor(0.0,0.0,0.0,1.0)

  currentAngle = 0.0
  g_last = Date.now()

  draw = (gl,n,currentAngle) ->
    m = Matrix.rotation(currentAngle,0,0,1).translate(0.35,0,0)
    program.setUniformMatrix 'u_ModelMatrix', m.array()
    gl.clear(gl.COLOR_BUFFER_BIT)
    gl.drawArrays(gl.POINTS, 0, n)

  animate = (angle) ->
    now = Date.now()
    elapsed = now - g_last
    g_last = now
    (angle + (45 * elapsed) / 1000.0) % 360

  tick = ->
    currentAngle = animate(currentAngle)
    draw(gl,n,currentAngle)
    requestAnimationFrame(tick)
  tick()

