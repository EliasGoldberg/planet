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

class Matrix
  constructor: (array) ->
    @m = if array? then array else
      [1,0,0,0,
       0,1,0,0,
       0,0,1,0,
       0,0,0,1]

  @identity: -> new Matrix(null)

  @rotation: (angle,x,y,z) ->
    radian = Math.PI * angle / 180.0
    cosB = Math.cos(radian)
    sinB = Math.sin(radian)
    new Matrix([
      cosB+x*x*(1-cosB),   y*x*(1-cosB)+z*sinB, z*x*(1-cosB)-y*sinB, 0.0,
      x*y*(1-cosB)-z*sinB, cosB + y*y*(1-cosB), z*y*(1-cosB)+x*sinB, 0.0,
      x*z*(1-cosB)+y*sinB, y*z*(1-cosB)-x*sinB, cosB+z*z*(1-cosB),   0.0,
                      0.0,                 0.0,               0.0,   1.0])

  @translation: (x,y,z) ->
    new Matrix([
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
        x,   y,   z, 1.0
    ])

  @scalation: (x,y,z) ->
    new Matrix([
        x, 0.0, 0.0, 0.0,
      0.0,   y, 0.0, 0.0,
      0.0, 0.0,   z, 0.0,
      0.0, 0.0, 0.0, 1.0
    ])

  rotate: (angle,x,y,z) ->
    Matrix.rotation(angle,x,y,z).multiply(this)

  translate: (x,y,z) ->
    Matrix.translation(x,y,z).multiply(this)

  scale: (x,y,z) ->
    Matrix.scalation(x,y,z).multiply(this)

  multiply: (b) ->
    n = b.m
    mn = []
    for i in [0..3]
      for j in [0..3]
        sum = 0
        for k in [0..3]
          sum += @m[4*i+k] * n[4*k+j]
        mn[i*4+j] = sum
    new Matrix(mn)

  array: -> new Float32Array(@m)

$(main)