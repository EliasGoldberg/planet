main = () ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('experimental-webgl')
  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      uniform mat4 u_xformMatrix;
      void main() {
           gl_Position = u_xformMatrix * a_Position;
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

  program.setUniformMatrix('u_xformMatrix',Matrix.rotation(90,0,0,1))
  n = program.setAttribPointer('a_Position',[0.0, 0.5, -0.5, -0.5, 0.5, -0.5])

  gl.drawArrays(gl.TRIANGLES, 0, n)

class Matrix
  constructor: ->

  @rotation: (angle,x,y,z) ->
    radian = Math.PI * angle / 180.0
    cosB = Math.cos(radian)
    sinB = Math.sin(radian)
    new Float32Array([
      cosB + x*x*(1-cosB), x*y*(1-cosB) - z*sinB,  x*z*(1-cosB)+y*sinB,  0.0,
      y*x*(1-cosB) + z*sinB, cosB + y*y*(1-cosB),  y*z*(1-cosB)-x*sinB,  0.0,
      z*x*(1-cosB) - y*sinB, z*y*(1-cosB)+x*sinB,    cosB+z*z*(1-cosB),  0.0,
                        0.0,                 0.0,                  0.0,  1.0
    ])

  @translation: (x,y,z) ->
    new Float32Array([
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
        x,   y,   z, 1.0
    ])

  @scale: (x,y,z) ->
    new Float32Array([
        x, 0.0, 0.0, 0.0,
      0.0,   y, 0.0, 0.0,
      0.0, 0.0,   z, 0.0,
      0.0, 0.0, 0.0, 1.0
    ])

$(main)