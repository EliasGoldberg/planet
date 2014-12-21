$ ->
  gl = document.getElementById('gl').getContext('webgl')
  gl.enable(gl.DEPTH_TEST)
  
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute vec4 a_Color;
      uniform mat4 u_ModelMatrix;
      uniform mat4 u_ViewMatrix;
      uniform mat4 u_ProjMatrix;
      varying vec4 v_Color;
      void main() {
        gl_Position = u_ProjMatrix * u_ViewMatrix * u_ModelMatrix * a_Position;
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
    
  cubeData = {
    vertices: [ 1.0,  1.0,  1.0,  1.0, 1.0, 1.0,
               -1.0,  1.0,  1.0,  1.0, 0.0, 1.0,
               -1.0, -1.0,  1.0,  1.0, 0.0, 0.0,
                1.0, -1.0,  1.0,  1.0, 1.0, 0.0,
                1.0, -1.0, -1.0,  0.0, 1.0, 0.0,
                1.0,  1.0, -1.0,  0.0, 1.0, 1.0,
               -1.0,  1.0, -1.0,  0.0, 0.0, 1.0,
               -1.0, -1.0, -1.0,  0.0, 0.0, 0.0]
    indices:  [ 0, 1, 2, 0, 2, 3,
                0, 3, 4, 0, 4, 5,
                0, 5, 6, 0, 6, 1,
                1, 6, 7, 1, 7, 2,
                7, 4, 3, 7, 3, 2,
                4, 7, 6, 4, 6, 5]
    stride: 6
    pointers: 
      [ {name: 'a_Position', dim: 3, offset: 0}
        {name: 'a_Color',    dim: 3, offset: 3} ]
    uniforms: []
    textures: []
  }
  
  view = Matrix.lookAt([3, 3, 7],[0,0,0],[0,1,0])
  proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
  program.setUniformMatrix('u_ProjMatrix', proj.array())
  program.setUniformMatrix('u_ViewMatrix', view.array())
  
  cube = new Model(cubeData,gl,program)
  cube.animate = (elapsed) ->
    model = Matrix.rotation(elapsed * .1 % 360, 0,1,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  cube.draw = -> gl.drawElements(gl.TRIANGLES, 36, gl.UNSIGNED_BYTE, 0)

  engine = new Engine(gl)
  engine.addModel(cube)
  engine.start()
