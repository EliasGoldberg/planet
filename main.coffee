main = () ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('experimental-webgl')
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      uniform mat4 u_ModelMatrix;
      void main() {
           gl_Position = u_ModelMatrix * a_Position;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
      }
    ''')

  program.activate()

  gl.clearColor(0.0,0.0,0.0,1.0)
  gl.clear(gl.COLOR_BUFFER_BIT)

  m = Matrix.identity()
  .rotate(60,0,0,1)
  .translate(0.5,0.0,0)
  .array()

  program.setUniformMatrix('u_ModelMatrix',m)
  n = program.setAttribPointer('a_Position',[0.0, 0.3, -0.3, -0.3, 0.3, -0.3])

  gl.drawArrays(gl.TRIANGLES, 0, n)

$(main)