class @Model

  constructor: (@gl,@program) ->
    @indexMap = {}
    @bufferByteCounts = {}

    @vertices = []
    @indices = []

    @stride = 6
    @pointers = [{name: 'a_Position', dim: 3, offset: 0}
                {name: 'a_Bary', dim: 3, offset: 3}]
    @uniforms = []
    @textures = []

    if @vertices.length > 0
      @arrayBuffer = this.makeArrayBuffer(@vertices)
      s = @bufferByteCounts[@arrayBuffer]
      @program.setAttribPointer(@arrayBuffer, p.name, p.dim, @stride*s, p.offset*s) for p in @pointers
      @indexBuffer = this.makeIndexBuffer(@indices)

    @program.setUniform(u.name, u.value) for u in @uniforms
    this.setupTexture(t.url, t.sampler, i) for t,i in @textures

  addFaces: (faces) ->
    for face in faces
      for i in [0..2]
        if (this.vertexExists(face.v[i]))
          indexList = @indexMap["#{face.v[i]}"]
          index = @indices[indexList[0]]
          indexList.push(@indices.length)
          @indices.push(index)
        else                                   # new vertex
          index = @vertices.length / @stride
          @indexMap["#{face.v[i]}"] = [@indices.length]
          bary = this.getBary(face,i)
          @vertices = @vertices.concat(face.v[i].elements()).concat(bary)
          @indices.push(index)

    @arrayBuffer = this.makeArrayBuffer(@vertices)
    s = @bufferByteCounts[@arrayBuffer]
    @program.setAttribPointer(@arrayBuffer, p.name, p.dim, @stride*s, p.offset*s) for p in @pointers
    @indexBuffer = this.makeIndexBuffer(@indices)

  makeArrayBuffer: (bufferData) ->
    if !@arrayBuffer? then @arrayBuffer = @gl.createBuffer()
    floatArray = new Float32Array(bufferData)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @arrayBuffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, floatArray, @gl.STATIC_DRAW)
    @bufferByteCounts[@arrayBuffer] = floatArray.BYTES_PER_ELEMENT
    @arrayBuffer

  makeIndexBuffer: (bufferData) ->
    if !@indexBuffer? then @indexBuffer = @gl.createBuffer()
    uIntArray = new Uint8Array(bufferData)
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @indexBuffer)
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, uIntArray, @gl.STATIC_DRAW)
    @bufferByteCounts[@indexBuffer] = uIntArray.BYTES_PER_ELEMENT
    @indexBuffer

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

  vertexExists: (v) ->
    indexList = @indexMap["#{v}"]
    indexList? && indexList.length > 0

  getBary: (face,i) ->
    existingBarys = (this.getExistingBary(v) for v,j in face.v when j != i and this.vertexExists(v))
    switch
      when existingBarys.length is 2 then this.uniqueBary(existingBarys[0], existingBarys[1])
      when existingBarys.length < 2 and i is 0 then [1,0,0]
      when existingBarys.length < 2 and i is 1 then [0,1,0]
      when existingBarys.length < 2 and i is 2 then [0,0,1]

  getExistingBary: (v) ->
    i = @indices[@indexMap["#{v}"][0]]*@stride+3
    b = @vertices[i..i+2]
    @vertices[i..i+2]

  uniqueBary: (a, b) -> [this.ubc(a[0],b[0]), this.ubc(a[1],b[1]), this.ubc(a[2],b[2])]
  ubc: (a, b) -> if a is 0 and b is 0 then 1 else 0