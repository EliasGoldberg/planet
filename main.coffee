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

  vertices =
    data: [ 0.0,  0.5, 10.0,
           -0.5, -0.5, 20.0,
            0.5, -0.5, 30.0 ]
    stride: 3
    pointers:[name: 'a_Position',  dim: 2, offset: 0
              name: 'a_PointSize', dim: 1, offset: 2]

  buffer = program.makeArrayBuffer(vertices.data)
  for p in vertices.pointers
    program.setAttribPointer(buffer,p.name, p.dim, vertices.stride, p.offset)

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