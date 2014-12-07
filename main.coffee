$ ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('webgl')

  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute vec4 a_Color;
      uniform mat4 u_ViewMatrix;
      varying vec4 v_Color;
      void main() {
        gl_Position = u_ViewMatrix * a_Position;
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
    data: [ 0.0,  0.5, -0.4, 0.4, 1.0, 0.4,  # back green triangle
           -0.5, -0.5, -0.4, 0.4, 1.0, 0.4,
            0.5, -0.5, -0.4, 1.0, 0.4, 0.4,
            0.5,  0.4, -0.2, 1.0, 0.4, 0.4,  # middle yellow triangle
           -0.5,  0.4, -0.2, 1.0, 1.0, 0.4,
            0.0, -0.6, -0.2, 1.0, 1.0, 0.4,
            0.0,  0.5,  0.0, 0.4, 0.4, 1.0,  # front blue triangle
           -0.5, -0.5,  0.0, 0.4, 0.4, 1.0,
            0.5, -0.5,  0.0, 1.0, 0.4, 0.4]
    stride: 6
    pointers:[
      {name: 'a_Position', dim: 3, offset: 0},
      {name: 'a_Color',    dim: 3, offset: 3}]
    uniforms:[]
    textures:[]

  model = new Model(vertices,gl,program)

  model.animate = (elapsed) ->
    view = Matrix.lookAt([0.20, 0.25, 0.25],[0,0,0],[0,1,0])
    program.setUniformMatrix('u_ViewMatrix', view.array())

  model.draw = -> gl.drawArrays(gl.TRIANGLES, 0, 9)

  engine = new Engine(gl)
  engine.addModel(model)
  engine.start()