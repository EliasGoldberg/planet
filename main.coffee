main = () ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('experimental-webgl')
  program = new Program(gl)

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

  program.setUniformMatrix('u_xformMatrix',Matrix.scale(0.5,0.5,0))
  n = program.setAttribPointer('a_Position',[0.0, 0.5, -0.5, -0.5, 0.5, -0.5])

  gl.drawArrays(gl.TRIANGLES, 0, n)

class Program
  constructor: (@gl) -> @program = @gl.createProgram()

  addShader: (type,source) ->
    shader = @gl.createShader(type)
    @gl.shaderSource(shader,source)
    @gl.compileShader(shader)
    message = @gl.getShaderInfoLog(shader)
    console.log message if message? and message != ''
    @gl.attachShader(@program,shader)

  activate: ->
    @gl.linkProgram(@program)
    message = @gl.getProgramInfoLog(@program)
    console.log message if message? and message != ''
    @gl.useProgram(@program)

  setAttrib: (name,value) ->
    attrib = @gl.getAttribLocation(@program,name)
    vertexAttrib = this.getVertexAttribMethodName(value)
    @gl[vertexAttrib](attrib,value)

  setUniform: (name,value) ->
    uniform = @gl.getUniformLocation(@program, name)
    @gl.uniform4fv(uniform,value)

  setUniformMatrix: (name, value) ->
    uniform = @gl.getUniformLocation(@program, name)
    @gl.uniformMatrix4fv(uniform,false,value)

  setAttribPointer: (name,values) ->
    attrib = @gl.getAttribLocation(@program,name)
    vertexBuffer = @gl.createBuffer();
    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexBuffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(values), @gl.STATIC_DRAW)
    @gl.vertexAttribPointer(attrib, 2, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(attrib)
    values.length / 2

  getVertexAttribMethodName: (value) ->
    isVector = value.length?
    size = if isVector then value.length else 1
    vee = if isVector then 'v' else ''
    "vertexAttrib#{size}f#{vee}"

class Matrix
  constructor: ->

  @rotation: (angle) ->
    radian = Math.PI * angle / 180.0
    cosB = Math.cos(radian)
    sinB = Math.sin(radian)
    new Float32Array([
      cosB, sinB,  0.0,  0.0,
      sinB, cosB,  0.0,  0.0,
      0.0,  0.0,  1.0,  0.0,
      0.0,  0.0,  0.0,  1.0
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