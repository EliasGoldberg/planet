class @Model

  constructor: (@gl,@program,@faces) ->
    @bufferByteCounts = {}

    @vertices = []

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

  vertexCount: () -> @vertices.length / @stride

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
    new Model(@gl,@program,newFaces)

  addFaces: (faces) ->
    for face,fIdx in faces
      for i in [0..2]
        vertex = face.v[i]
        @vertices = @vertices.concat(vertex.elements()).concat(face.b[i]).concat([fIdx])

  buildModel: ->
    @arrayBuffer = this.makeArrayBuffer(@vertices)
    s = @bufferByteCounts[@arrayBuffer]
    @program.setAttribPointer(@arrayBuffer, p.name, p.dim, @stride*s, p.offset*s) for p in @pointers

  activate: ->
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @arrayBuffer);
    s = @bufferByteCounts[@arrayBuffer]
    @program.setAttribPointer(@arrayBuffer, p.name, p.dim, @stride*s, p.offset*s) for p in @pointers

  makeArrayBuffer: (bufferData) ->
    if !@arrayBuffer? then @arrayBuffer = @gl.createBuffer()
    floatArray = new Float32Array(bufferData)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @arrayBuffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, floatArray, @gl.STATIC_DRAW)
    @bufferByteCounts[@arrayBuffer] = floatArray.BYTES_PER_ELEMENT
    @arrayBuffer

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