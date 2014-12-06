$ ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('webgl')
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute float a_PointSize;
      attribute vec4 a_Color;
      varying vec4 v_Color;
      uniform mat4 u_ModelMatrix;
      void main() {
        gl_Position = u_ModelMatrix * a_Position;
        gl_PointSize = a_PointSize;
        v_Color = a_Color;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      precision mediump float;
      varying vec4 v_Color;
      void main() {
        gl_FragColor = v_Color;
      }
    ''')

  program.activate()

  vertices =
    data: [ 0.0,  0.5, 10.0, 1.0, 0.0, 0.0,
           -0.5, -0.5, 20.0, 0.0, 1.0, 0.0,
            0.5, -0.5, 30.0, 0.0, 0.0, 1.0 ]
    stride: 6
    pointers:[
      {name: 'a_Position',  dim: 2, offset: 0},
      {name: 'a_PointSize', dim: 1, offset: 2},
      {name: 'a_Color',     dim: 3, offset: 3}]

  new Model(vertices,gl,program)

  gl.clearColor(0.0,0.0,0.0,1.0)

  currentAngle = 0.0
  g_last = Date.now()

  draw = (gl, currentAngle) ->
    m = Matrix.rotation(currentAngle,0,0,1).translate(0.35,0,0)
    program.setUniformMatrix 'u_ModelMatrix', m.array()
    gl.clear(gl.COLOR_BUFFER_BIT)
    gl.drawArrays(gl.POINTS, 0, 3)

  animate = (angle) ->
    now = Date.now()
    elapsed = now - g_last
    g_last = now
    (angle + (45 * elapsed) / 1000.0) % 360

  tick = ->
    currentAngle = animate(currentAngle)
    draw(gl,currentAngle)
    requestAnimationFrame(tick)
  tick()