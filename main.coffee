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
    
  vertices = {
    data: [ 0.0,  1.0, 0.0, 0.4, 1.0, 0.4,        # green back
           -0.5, -1.0, 0.0, 0.4, 1.0, 0.4,
            0.5, -1.0, 0.0, 1.0, 0.4, 0.4,
            
            0.0,  1.0, -2.0, 1.0, 1.0, 0.4,        # yellow middle
           -0.5, -1.0, -2.0, 1.0, 1.0, 0.4,
            0.5, -1.0, -2.0, 1.0, 0.4, 0.4,
            
            0.0,  1.0, -4.0, 0.4, 0.4, 1.0,         # blue front
           -0.5, -1.0, -4.0, 0.4, 0.4, 1.0,
            0.5, -1.0, -4.0, 1.0, 0.4, 0.4]
    stride: 6
    pointers: 
      [ {name: 'a_Position', dim: 3, offset: 0}
        {name: 'a_Color',    dim: 3, offset: 3} ]
    uniforms: []
    textures: []
  }
  
  view = Matrix.lookAt([0, 0, 5],[0,0,-100],[0,1,0])
  proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
  program.setUniformMatrix('u_ProjMatrix', proj.array())
  program.setUniformMatrix('u_ViewMatrix', view.array())
  
  leftTriangles = new Model(vertices,gl,program)
  leftTriangles.animate = (elapsed) ->
    model = Matrix.translation(-0.75,0,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  leftTriangles.draw = -> gl.drawArrays(gl.TRIANGLES, 0, 9)
  
  rightTriangles = new Model(vertices,gl,program)
  rightTriangles.animate = (elapsed) ->
    model = Matrix.translation(0.75,0,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  rightTriangles.draw = -> gl.drawArrays(gl.TRIANGLES, 0, 9)

  engine = new Engine(gl)
  engine.addModel(leftTriangles)
  engine.addModel(rightTriangles)
  engine.start()
