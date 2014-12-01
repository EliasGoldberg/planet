class @ShaderProgram
  constructor: (@gl) ->
    @program = @gl.createProgram()
    @bufferBytes = {}

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

  makeArrayBuffer: (bufferData) ->
    buffer = @gl.createBuffer()
    floatArray = new Float32Array(bufferData)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, floatArray, @gl.STATIC_DRAW)
    @bufferBytes[buffer] = floatArray.BYTES_PER_ELEMENT
    buffer

  setAttribPointer: (buffer,name,dim,stride,offset) ->
    s = @bufferBytes[buffer]
    attrib = @gl.getAttribLocation(@program,name)
    @gl.vertexAttribPointer(attrib, dim, @gl.FLOAT, false, stride*s, offset*s)
    @gl.enableVertexAttribArray(attrib)

  getVertexAttribMethodName: (value) ->
    isVector = value.length?
    size = if isVector then value.length else 1
    vee = if isVector then 'v' else ''
    "vertexAttrib#{size}f#{vee}"