class @ShaderProgram
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