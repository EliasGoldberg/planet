class @Model
  constructor: (@modelData,@gl,@program) ->
    @bufferBytes = {}
    buffer = this.makeArrayBuffer(@modelData.data)
    for p in @modelData.pointers
      this.setAttribPointer(buffer, p.name, p.dim, @modelData.stride, p.offset)

  makeArrayBuffer: (bufferData) ->
    buffer = @gl.createBuffer()
    floatArray = new Float32Array(bufferData)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, floatArray, @gl.STATIC_DRAW)
    @bufferBytes[buffer] = floatArray.BYTES_PER_ELEMENT
    buffer

  setAttribPointer: (buffer,name,dim,stride,offset) ->
    s = @bufferBytes[buffer]
    attrib = @gl.getAttribLocation(@program.id,name)
    @gl.vertexAttribPointer(attrib, dim, @gl.FLOAT, false, stride*s, offset*s)
    @gl.enableVertexAttribArray(attrib)