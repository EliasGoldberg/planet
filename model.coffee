class @Model
  constructor: (@model,@gl,@program) ->
    @bufferBytes = {}
    buf = this.makeArrayBuffer(@model.data)
    s = @bufferBytes[buf]
    for p in @model.pointers
      @program.setAttribPointer(buf, p.name, p.dim, @model.stride*s, p.offset*s)
    for u in @model.uniforms
      @program.setUniform(u.name, u.value);
    i=0
    for t in @model.textures
      this.setupTexture(t.url, t.sampler, i)
      i+=1

  makeArrayBuffer: (bufferData) ->
    buffer = @gl.createBuffer()
    floatArray = new Float32Array(bufferData)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, floatArray, @gl.STATIC_DRAW)
    @bufferBytes[buffer] = floatArray.BYTES_PER_ELEMENT
    buffer

  setupTexture: (url,sampler,i) ->
    img = new Image()
    img.onload = =>
      texture = @gl.createTexture()
      @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL,1)
      @gl.activeTexture(@gl["TEXTURE#{i}"])
      @gl.bindTexture(@gl.TEXTURE_2D,texture)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
      @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, img)
      @program.setUniform(sampler,i)
    img.src = url