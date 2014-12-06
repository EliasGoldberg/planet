class @ShaderProgram
  constructor: (@gl) ->
    @id = @gl.createProgram()
    @bufferBytes = {}

  addShader: (type,source) ->
    shader = @gl.createShader(type)
    @gl.shaderSource(shader,source)
    @gl.compileShader(shader)
    message = @gl.getShaderInfoLog(shader)
    console.log message if message? and message != ''
    @gl.attachShader(@id,shader)

  activate: ->
    @gl.linkProgram(@id)
    message = @gl.getProgramInfoLog(@id)
    console.log message if message? and message != ''
    @gl.useProgram(@id)

  setAttrib: (name,value) ->
    attrib = @gl.getAttribLocation(@id,name)
    @gl["vertexAttrib#{this.getMethodSuffix(value)}"](attrib,value)

  setAttribPointer: (buffer,name,dim,stride,offset) ->
    attrib = @gl.getAttribLocation(@id,name)
    @gl.vertexAttribPointer(attrib, dim, @gl.FLOAT, false, stride, offset)
    @gl.enableVertexAttribArray(attrib)

  setUniform: (name,value) ->
    uniform = @gl.getUniformLocation(@id, name)
    @gl["uniform#{this.getMethodSuffix(value)}"](uniform,value)

  setUniformMatrix: (name, value) ->
    uniform = @gl.getUniformLocation(@id, name)
    @gl.uniformMatrix4fv(uniform,false,value)

  getMethodSuffix: (value) ->
    isVector = value.length?
    size = if isVector then value.length else 1
    vee = if isVector then 'v' else ''
    "#{size}f#{vee}"