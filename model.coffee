class @Model
  constructor: (@model,@gl,@program) ->
    @bufferBytes = {}
    buf = this.makeArrayBuffer(@model.data)
    s = @bufferBytes[buf]
    for p in @model.pointers
      @program.setAttribPointer(buf, p.name, p.dim, @model.stride*s, p.offset*s)
    for u in @model.uniforms
      @program.setUniform(u.name, u.value);

  makeArrayBuffer: (bufferData) ->
    buffer = @gl.createBuffer()
    floatArray = new Float32Array(bufferData)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, floatArray, @gl.STATIC_DRAW)
    @bufferBytes[buffer] = floatArray.BYTES_PER_ELEMENT
    buffer
