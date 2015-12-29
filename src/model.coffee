class @Model

  constructor: (@gl,@program,@faces) ->
    @vertexToIndexMap = {}
    @faceToIndexLocationMap = {}
    @vertexReferenceCounts = {}
    @bufferByteCounts = {}

    @vertices = []
    @indices = []

    @stride = 7
    @pointers = [{name: 'a_Position', dim: 3, offset: 0}
                {name: 'a_Bary', dim: 3, offset: 3}
                {name: 'a_Triangle', dim: 1, offset:6}]
    @uniforms = []
    @textures = []
    @modifiers = []

    @program.setUniform(u.name, u.value) for u in @uniforms
    this.setupTexture(t.url, t.sampler, i) for t,i in @textures
    this.addFaces(@faces)
    this.buildModel()

  detail: (pvm,camera) ->
    results = {add: [], remove: []}
    for face in @faces
      face.detail(pvm,camera,results)
    if results.remove.length > 0 or results.add.length > 0
      this.removeFaces(results.remove)
      this.addFaces(results.add)
      this.buildModel()

  tessellate: (subdivisions,midpointFunction) ->
    newFaces = []
    for face in this.faces
      subFaces = face.tessellate(subdivisions,midpointFunction)
      newFaces = newFaces.concat(subFaces)
    this.addFaces(newFaces)
    this.removeFaces(this.faces)
    this.buildModel()

  addFaces: (faces) ->
    for face,fIdx in faces
      @faceToIndexLocationMap[face.toString()] = @indices.length
      for i in [0..2]
        vertex = face.v[i]
        if not this.vertexExists(vertex)
          bary = this.getBary(face,i)
          face.setBary(bary,i)
          @vertices = @vertices.concat(vertex.elements()).concat(bary).concat([fIdx])
          @vertexReferenceCounts[vertex.toString()] = 1
        else
          @vertexReferenceCounts[vertex.toString()]++
          bary = this.getBary(face,i)
          face.setBary(bary,i)
        this.addIndex(vertex)

  addIndex: (v) ->
    isNew = not this.vertexExists(v)
    if isNew then @vertexToIndexMap[v.toString()] = @vertices.length / @stride - 1
    index = @vertexToIndexMap[v.toString()]
    @indices.push(index)

  removeFaces: (faces) ->
    vertexRefCountToZero = 0
    laterIndexIndices = 0
    laterIndexVtoIMap = 0
    for face in faces
      for vertex in face.v
        @vertexReferenceCounts[vertex.toString()]--
        if @vertexReferenceCounts[vertex.toString()] is 0
          vertexRefCountToZero++
          index = @vertexToIndexMap[vertex.toString()]
          @vertices.splice(index*@stride,@stride)
          delete @vertexToIndexMap[vertex.toString()]
          for laterIndex,i in @indices when laterIndex > index
            @indices[i]--
            laterIndexIndices++
          for v,laterIndex of @vertexToIndexMap when laterIndex  > index
            @vertexToIndexMap[v]--
            laterIndexVtoIMap++

      location = @faceToIndexLocationMap[face.toString()]
      @indices.splice(location, 3)
      delete @faceToIndexLocationMap[face.toString()]
      for otherFace,otherLocation of @faceToIndexLocationMap when otherLocation > location
        @faceToIndexLocationMap[otherFace] = otherLocation - 3

  vertexExists: (v) -> @vertexToIndexMap[v.toString()]?

  getBary: (face,i) ->
    if face.b[i]? then return face.b[i]
    existingBarys = (this.getExistingBary(v) for v,j in face.v when j != i and this.vertexExists(v))
    switch
      when existingBarys.length is 2 then Vector.nor existingBarys[0], existingBarys[1]
      when existingBarys.length < 2 and i is 0 then [1,0,0]
      when existingBarys.length < 2 and i is 1 then [0,1,0]
      when existingBarys.length < 2 and i is 2 then [0,0,1]

  getExistingBary: (v) ->
    i = @vertexToIndexMap[v.toString()]*@stride+3
    @vertices[i..i+2]

  buildModel: ->
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
    uIntArray = new Uint16Array(bufferData)
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

  addModifier: (label,f) -> @modifiers[label] = f
  removeModifier: (label) -> delete @modifiers[label]
  applyModifiers: () ->
    for label,f of @modifiers
      for i in [0..@vertices.length-1] by @stride
        v = new Vector(@vertices[i..i+2])
        mod = f(v).elements()
        @vertices.splice(i,3,mod[0],mod[1],mod[2])
    @buildModel()