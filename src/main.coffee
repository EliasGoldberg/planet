$ ->
  canvas = setCanvasSize()
  gl = canvas.getContext('webgl2')
  gl.enable(gl.DEPTH_TEST)
  gl.enable(gl.CULL_FACE)
  gl.clearColor(0.1,0.0,0.5,1.0)
  RADIUS = 6370000
  #RADIUS = 10

  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
    #version 300 es
    #define M_PI 3.1415926535897932384626433832795
    in highp vec4 a_Position;
    in vec3 a_Bary;
    in float a_Triangle;
    out vec3 v_Bary;
    flat out int v_Triangle;
    flat out int v_InstanceId;
    uniform mediump mat4 u_ModelMatrix;
    uniform mediump mat4 u_ViewMatrix;
    uniform mediump mat4 u_ProjMatrix;
    uniform mediump mat4 u_PatchMatrix[128];
    uniform mediump vec2 u_discardPile[128];
    uniform mediump float u_discardCount;

    void main() {
      vec4 pos = a_Position;

      pos = u_PatchMatrix[gl_InstanceID] * pos;
      pos = vec4(normalize(pos.xyz),1.0);
      pos = vec4(pos.xyz*float(''' + RADIUS.toString() + '''),1.0);

      pos = u_ProjMatrix * u_ViewMatrix * u_ModelMatrix * pos;
      gl_Position = pos;
      v_Bary = a_Bary;
      v_Triangle = int(a_Triangle);
      v_InstanceId = gl_InstanceID;
    }
  ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
    #version 300 es
    #define M_PI 3.1415926535897932384626433832795
    precision mediump float;
    in vec3 v_Bary;
    flat in int v_Triangle;
    flat in int v_InstanceId;
    out vec4 fragcolor;
    uniform mediump vec2 u_discardPile[128];
    uniform mediump float u_discardCount;

    float edgeFactor(){
      vec3 d = fwidth(v_Bary);
      vec3 a3 = smoothstep(vec3(0.0), 1.25*d, v_Bary);
      return min(min(a3.x, a3.y), a3.z);
    }

    void main() {
      for (int i = 0; i<int(u_discardCount);++i) {
        if (int(u_discardPile[i].x) == v_InstanceId && int(u_discardPile[i].y) == v_Triangle) discard;
      }

      vec3 faceColor = vec3(1.0,0.5,0.0);
      vec3 wireColor = vec3(0, 0, 0);
      fragcolor = vec4(mix(wireColor, faceColor, edgeFactor()),1);
    }
  ''')

  diffX = 0
  diffY = 0
  dragging = false
  x = 0
  y = 0
  rX = 0
  rY = 0
  z = RADIUS * 4

  program.activate()

  setSize = -> gl.viewport(0, 0, canvas.width, canvas.height)

  setSize()

  $(window).resize(->
    setCanvasSize()
    setSize()
  )

  v0 = new Vector([0, 1, 0])
  v1 = new Vector([0, 0, 1])
  v2 = new Vector([1, 0, 0])
  tess = 3
  scaler = 1/Math.pow(2,tess)
  rawFace = new Face(v0,v1,v2)
  octahedron = new Model(gl,program,rawFace.tessellate(tess))

  discards = []
  patchArray = []
  patchMatrices = []
  octantTransforms = [
    Matrix.identity(),
    Matrix.rotation(90,0,1,0),
    Matrix.rotation(180,0,1,0),
    Matrix.rotation(270,0,1,0),
    Matrix.scalation(-1,-1,1),
    Matrix.scalation(-1,-1,1).rotate(90,0,1,0),
    Matrix.scalation(-1,-1,1).rotate(180,0,1,0),
    Matrix.scalation(-1,-1,1).rotate(270,0,1,0)
  ]
  octantArrays = []
  for transformation in octantTransforms
    octantArrays = octantArrays.concat(transformation.m)

  tessellate = (model, proj, view) ->
    patchArray = [].concat(octantArrays)
    patchMatrices = [].concat(octantTransforms)
    possiblePatches = []
    matIdx = 0
    discards = []
    while matIdx < patchMatrices.length and patchMatrices.length < 128
      matrix = patchMatrices[matIdx]

      newPatches = rawFace.getPossiblePatches(new Vector([0,0,z]),matrix,model,proj,view,canvas.width, canvas.height, matIdx)

      for possiblePatch,i in newPatches
        discards.push(possiblePatch.parentInstance)
        discards.push(possiblePatch.id)
        discardOctant = possiblePatch.parentInstance
        discardFace = possiblePatch.id

        centerFlip = octahedron.faces[discardFace].isUpsidedown * 180
        axis = octahedron.faces[discardFace].getNormal()

        patchMatrix = Matrix.identity()
        nested = true
        while nested
          f = octahedron.faces[discardFace]
          d = f.centroid.minus(octahedron.faces[0].centroid)
          patchMatrix = patchMatrix.multiply(
            Matrix.scalation(scaler,scaler,scaler)
            .translate(d.a[0],d.a[1],d.a[2])
            .translate(v0.a[0]*(1-scaler),v0.a[1]*(1-scaler),v0.a[2]*(1-scaler))
          )
          nested = false

        patchMatrix = matrix
          .multiply(patchMatrix)
          .multiply(Matrix.rotation(centerFlip,axis.a[0],axis.a[1],axis.a[2]))
        patchArray = patchArray.concat(patchMatrix.m)
        patchMatrices.push(patchMatrix)
      matIdx += 1
      possiblePatches = possiblePatches.concat(newPatches)

    program.setUniformVectorArray('u_discardPile',discards,2)
    program.setUniform('u_discardCount',discards.length / 2)
    program.setUniformMatrix('u_PatchMatrix',patchArray)

  diffX = 0
  diffY = 0
  dragging = false
  x = 0
  y = 0
  rX = 0
  rY = 0
  z = RADIUS * 4

  $(document.body).append('<div id="overlay"></div>')
  $('#overlay').css({ position:'fixed', backgroundColor:'black', color:'white', left:10 + 'px', top:10 + 'px' })

  $(document.body).append('<div id="lower-left"></div>')
  $('#lower-left').css({ position:'fixed', backgroundColor:'black', color:'white', left:10 + 'px', bottom:10 + 'px' })

  $(document.body).append('<div id="vert-0-0"></div>')
  $(document.body).append('<div id="vert-0-1"></div>')
  $(document.body).append('<div id="vert-0-2"></div>')
  $(document.body).append('<div id="area"></div>')

  frame = 0
  octahedron.animate = (elapsed) ->
    rX += if dragging? and dragging then diffX else 0
    rY += if dragging? and dragging then diffY else 0
    model = Matrix.rotation(-rX * 0.4 % 360, 0,1,0).multiply(
      Matrix.rotation(-rY * 0.4 % 360, 1,0,0))
    program.setUniformMatrix('u_ModelMatrix', model.array())
    view = Matrix.lookAt([0, 0, z],[0,0,0],[0,1,0])
    program.setUniformMatrix('u_ViewMatrix', view.array())
    proj = Matrix.perspective(90, canvas.width / canvas.height, z-RADIUS-1, z+RADIUS+500)
    program.setUniformMatrix('u_ProjMatrix', proj.array())

    tessellate(model,proj,view)

    frame += 1
    if (frame % 60 is 0)
      $('#lower-left').text(
        """
           #{patchMatrices.length}
           #{discards.length}
        """)

  octahedron.draw = ->
    octahedron.activate()
    gl.drawArraysInstanced(gl.TRIANGLES, 0, octahedron.vertexCount(), 8 + (discards.length / 2))

  engine = new Engine(gl)
  engine.addModel(octahedron)
  engine.start()

  $("#gl").mousedown((e) ->
    x = e.pageX
    y = e.pageY
    dragging = true
  )

  $("#gl").mousemove((e) ->
    diffX = if x? then x - e.pageX else 0
    diffY = if y? then y - e.pageY else 0
    x = e.pageX
    y = e.pageY
  )

  $("#gl").mouseup (e)-> dragging = false
  $('#gl').mousewheel (e) ->
    toSurface = z-RADIUS
    z = Math.max(RADIUS+2,z + toSurface * e.deltaY * 0.01)

setCanvasSize = ->
  canvas = document.getElementById('gl')
  devicePixelRatio = window.devicePixelRatio || 1
  overdraw = 1
  scale = devicePixelRatio * overdraw
  canvas.width  = window.innerWidth  * scale
  canvas.height = window.innerHeight * scale
  canvas.style.width  = window.innerWidth  + "px"
  canvas.style.height = window.innerHeight + "px"
  canvas
