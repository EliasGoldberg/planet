$ ->
  gl = document.getElementById('gl').getContext('webgl')
  gl.enable(gl.DEPTH_TEST)
  
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      uniform mat4 u_ModelMatrix;
      uniform mat4 u_ViewMatrix;
      uniform mat4 u_ProjMatrix;
      void main() {
        gl_Position = u_ProjMatrix * u_ViewMatrix * u_ModelMatrix * a_Position;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      precision mediump float;
      void main() {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
      }
    ''')
    
  program.activate()
  
  r = (1 + Math.sqrt 5) / 2
  icosahedronData = {
    vertices: [-1,  r,  0,
                1,  r,  0,
               -1, -r,  0,
                1, -r,  0,
                0, -1,  r,
                0,  1,  r,
                0, -1, -r,
                0,  1, -r,
                r,  0, -1,
                r,  0,  1,
               -r,  0, -1,
               -r,  0,  1]
    indices: 
      [0, 11,  5,  0,  5,  1,  0,  1,  7,  0,  7, 10,  0, 10, 11,
       1,  5,  9,  5, 11,  4, 11, 10,  2, 10,  7,  6,  7,  1,  8,
       3,  9,  4,  3,  4,  2,  3,  2,  6,  3,  6,  8,  3,  8,  9,
       4,  9,  5,  2,  4, 11,  6,  2, 10,  8,  6,  7,  9,  8,  1]
    stride: 3
    pointers:
      [ { name: 'a_Position', dim: 3, offset: 0 } ]
    uniforms: []
    textures: []
  }
  
  view = Matrix.lookAt([3, 3, 7],[0,0,0],[0,1,0])
  proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
  program.setUniformMatrix('u_ProjMatrix', proj.array())
  program.setUniformMatrix('u_ViewMatrix', view.array())
  
  icosahedron = new Model(icosahedronData,gl,program)
  icosahedron.animate = (elapsed) ->
    model = Matrix.rotation(elapsed * .1 % 360, 0,1,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  icosahedron.draw = -> gl.drawElements(gl.TRIANGLES, 60, gl.UNSIGNED_BYTE, 0)

  engine = new Engine(gl)
  engine.addModel(icosahedron)
  engine.start()
