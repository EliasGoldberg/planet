$ ->
  gl = document.getElementById('gl').getContext('webgl')
  gl.enable(gl.DEPTH_TEST)
  gl.clearColor(0.5,0.6,0.7,1.0)
  gl.getExtension('OES_standard_derivatives');
  
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute vec3 a_Bary;
      varying vec3 v_Bary;
      uniform mat4 u_ModelMatrix;
      uniform mat4 u_ViewMatrix;
      uniform mat4 u_ProjMatrix;
      void main() {
        gl_Position = u_ProjMatrix * u_ViewMatrix * u_ModelMatrix * a_Position;
        v_Bary = a_Bary;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      #extension GL_OES_standard_derivatives : enable
      precision mediump float;
      varying vec3 v_Bary;

      float edgeFactor(){
        vec3 d = fwidth(v_Bary);
        vec3 a3 = smoothstep(vec3(0.0), 1.5*d, v_Bary);
        return min(min(a3.x, a3.y), a3.z);
      }
      
      void main() {
        gl_FragColor = vec4(mix(vec3(0.0), vec3(0.7, 0.6, 0.5), edgeFactor()),1.0);
      }
      ''')
    
  program.activate()

  octahedronData = {
    vertices: [0, 1, 0,  1, 0, 0,
               1, 0, 0,  0, 1, 0,
               0, 0, 1,  0, 0, 1,
              -1, 0, 0,  0, 1, 0,  
               0, 0,-1,  0, 0, 1,
               0,-1, 0,  1, 0, 0]
    indices: 
      [0, 1, 2, 
       0, 2, 3,
       0, 3, 4,
       0, 4, 1,
       5, 1, 2,
       5, 2, 3,
       5, 3, 4,
       5, 4, 1]
    stride: 6
    pointers:
      [ { name: 'a_Position', dim: 3, offset: 0 }
        { name: 'a_Bary',     dim: 3, offset: 3 } ]
    uniforms: []
    textures: []
  }
  
  view = Matrix.lookAt([3, 3, 7],[0,0,0],[0,1,0])
  proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
  program.setUniformMatrix('u_ProjMatrix', proj.array())
  program.setUniformMatrix('u_ViewMatrix', view.array())

  octahedron = new Model(octahedronData,gl,program)
  octahedron.animate = (elapsed) ->
    model = Matrix.rotation(elapsed * .1 % 360, 0,1,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  octahedron.draw = -> gl.drawElements(gl.TRIANGLES, 24, gl.UNSIGNED_BYTE, 0)

  engine = new Engine(gl)
  engine.addModel(octahedron)
  engine.start()
