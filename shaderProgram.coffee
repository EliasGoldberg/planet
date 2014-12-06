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
    vertexAttrib = this.getVertexAttribMethodName(value)
    @gl[vertexAttrib](attrib,value)

  setUniform: (name,value) ->
    uniform = @gl.getUniformLocation(@id, name)
    @gl.uniform4fv(uniform,value)

  setUniformMatrix: (name, value) ->
    uniform = @gl.getUniformLocation(@id, name)
    @gl.uniformMatrix4fv(uniform,false,value)

  getVertexAttribMethodName: (value) ->
    isVector = value.length?
    size = if isVector then value.length else 1
    vee = if isVector then 'v' else ''
    "vertexAttrib#{size}f#{vee}"