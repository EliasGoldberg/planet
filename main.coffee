$ ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('webgl')
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      uniform mat4 u_ModelMatrix;
      void main() {
        gl_Position = u_ModelMatrix * a_Position;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      precision mediump float;
      uniform float u_Width;
      uniform float u_Height;
      void main() {
        gl_FragColor = vec4(gl_FragCoord.x/u_Width, 0.0,
                            gl_FragCoord.y/u_Height, 1.0);
      }
    ''')

  program.activate()

  vertices =
    data: [ 0.0,  0.5,
           -0.5, -0.5,
            0.5, -0.5 ]
    stride: 2
    pointers:[
      {name: 'a_Position',  dim: 2, offset: 0}],
    uniforms:[
      {name: 'u_Width',  value: gl.drawingBufferWidth},
      {name: 'u_Height', value: gl.drawingBufferHeight}]

  new Model(vertices,gl,program)

  gl.clearColor(0.0,0.0,0.0,1.0)

  currentAngle = 0.0
  g_last = Date.now()

  draw = (gl, currentAngle) ->
    m = Matrix.rotation(currentAngle,0,0,1).translate(0.35,0,0)
    program.setUniformMatrix 'u_ModelMatrix', m.array()
    gl.clear(gl.COLOR_BUFFER_BIT)
    gl.drawArrays(gl.TRIANGLES, 0, 3)

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