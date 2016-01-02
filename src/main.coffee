$ ->
  canvas = setCanvasSize()
  gl = canvas.getContext('webgl2')
  gl.enable(gl.DEPTH_TEST)
  gl.enable(gl.CULL_FACE)
  gl.clearColor(0.1,0.0,0.5,1.0)
  RADIUS = 6370000

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
    uniform mediump mat4 u_PatchMatrix[64];
    uniform mediump vec2 u_discardPile[64];
    uniform mediump float u_discardCount;

    mat4 oMat[8] = mat4[](
      //    0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
      mat4( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),      // 0
      mat4( 0, 0, 1, 0, 0, 1, 0, 0,-1, 0, 0, 0, 0, 0, 0, 1),      // 1
      mat4(-1, 0, 0, 0, 0, 1, 0, 0, 0, 0,-1, 0, 0, 0, 0, 1),      // 2
      mat4( 0, 0,-1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1),      // 3
      mat4(-1, 0, 0, 0, 0,-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),      // 4
      mat4( 0, 0,-1, 0, 0,-1, 0, 0,-1, 0, 0, 0, 0, 0, 0, 1),      // 5
      mat4( 1, 0, 0, 0, 0,-1, 0, 0, 0, 0,-1, 0, 0, 0, 0, 1),      // 6
      mat4( 0, 0, 1, 0, 0,-1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1));     // 7

    void main() {
      vec4 pos = a_Position;
      
      if (gl_InstanceID < 8) {
        pos = vec4(normalize(pos.xyz),1.0);
        pos = vec4(pos.xyz*float(''' + RADIUS.toString() + '''),1.0);
        pos = oMat[gl_InstanceID] * pos;
      } else {
        pos = u_PatchMatrix[gl_InstanceID-8] * pos;
        pos = vec4(normalize(pos.xyz),1.0);
        pos = vec4(pos.xyz*float(''' + RADIUS.toString() + '''),1.0);
        pos = oMat[int(u_discardPile[gl_InstanceID-8].x)] * pos;
      }
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
    uniform mediump vec2 u_discardPile[64];
    uniform mediump float u_discardCount;

    vec3 colors[8] = vec3[](
        vec3(1.0,1.0,1.0),   // 0 - white
        vec3(1.0,1.0,0.0),   // 1 - yellow
        vec3(1.0,0.0,1.0),   // 2 - purple
        vec3(1.0,0.0,0.0),   // 3 - red
        vec3(0.0,1.0,1.0),   // 4 - teal
        vec3(0.0,1.0,0.0),   // 5 - green
        vec3(0.0,0.0,1.0),   // 6 - blue
        vec3(0.2,0.2,0.2));  // 7 - gray

    float edgeFactor(){
      vec3 d = fwidth(v_Bary);
      vec3 a3 = smoothstep(vec3(0.0), 1.25*d, v_Bary);
      return min(min(a3.x, a3.y), a3.z);
    }

    void main() {
      for (int i = 0; i<int(u_discardCount);++i) {
        if (int(u_discardPile[i].x) == v_InstanceId && int(u_discardPile[i].y) == v_Triangle) discard;
      }
      
      vec3 faceColor;
      if (v_InstanceId < 8)
        faceColor = colors[v_InstanceId];
      else
        faceColor = vec3(1.0,0.5,0.0);

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
  z = RADIUS * 2

  program.activate()

  setSize = ->
    gl.viewport(0, 0, canvas.width, canvas.height)
    proj = Matrix.perspective(45, canvas.width / canvas.height, z-RADIUS-1, z+RADIUS+500)
    program.setUniformMatrix('u_ProjMatrix', proj.array())

  setSize()

  $(window).resize(->
    setCanvasSize()
    setSize()
  )

  v0 = new Vector([0, 1, 0])
  v1 = new Vector([0, 0, 1])
  v2 = new Vector([1, 0, 0])
  octahedron = new Model(gl,program,new Face(v0,v1,v2).tessellate(3))

  discards = [ 0,0,  1,1,  2,2,  3,3,  4,4,  5,5,  6,6,  7,7, 
               0,8,  1,9, 2,10, 3,11, 4,12, 5,13, 6,14, 7,15,
              0,16, 1,17, 2,18, 3,19, 4,20, 5,21, 6,22, 7,23,
              0,24, 1,25, 2,26, 3,27, 4,28, 5,29, 6,30, 7,31,
              0,32, 1,33, 2,34, 3,35, 4,36, 5,37, 6,38, 7,39,
              0,40, 1,41, 2,42, 3,43, 4,44, 5,45, 6,46, 7,47,
              0,48, 1,49, 2,50, 3,51, 4,52, 5,53, 6,54, 7,55,
              0,56, 1,57, 2,58, 3,59, 4,60, 5,61, 6,62, 7,63]
  patchMatrices = []

  tessellate = ->
    patchMatrices = []
    for idx in [0..discards.length-1] by 2
      discardOctant = discards[idx]
      discardFace = discards[idx+1]
      axis = octahedron.faces[discardFace].getNormal(Matrix.identity())
      d = octahedron.faces[discardFace].centroid.minus(octahedron.faces[0].centroid)
      centerFlip = octahedron.faces[discardFace].isUpsidedown * 180
      lowerFlip = 0
      patchMatrix = Matrix.scalation(1/8,1/8,1/8)
        .rotate(centerFlip + lowerFlip,axis.a[0],axis.a[1],axis.a[2])
        .translate(d.a[0],d.a[1],d.a[2])
        .translate(v0.a[0]*(7/8),v0.a[1]*(7/8),v0.a[2]*(7/8))
      patchMatrices = patchMatrices.concat(patchMatrix.m)
    program.setUniformVectorArray('u_discardPile',discards,2)
    program.setUniform('u_discardCount',discards.length / 2)
    program.setUniformMatrix('u_PatchMatrix',patchMatrices)

  diffX = 0
  diffY = 0
  dragging = false
  x = 0
  y = 0
  rX = 0
  rY = 0
  z = RADIUS * 4

  $(document.body).append('<div id="overlay"></div>')
  $('#overlay').css({ position:'fixed', color:'white', left:10 + 'px', top:10 + 'px' })

  octahedron.animate = (elapsed) ->
    rX += if dragging? and dragging then diffX else 0
    rY += if dragging? and dragging then diffY else 0
    model = Matrix.rotation(-rX * 0.4 % 360, 0,1,0).multiply(
      Matrix.rotation(-rY * 0.4 % 360, 1,0,0))
    program.setUniformMatrix('u_ModelMatrix', model.array())
    view = Matrix.lookAt([0, 0, z],[0,0,0],[0,1,0])
    program.setUniformMatrix('u_ViewMatrix', view.array())
    proj = Matrix.perspective(45, canvas.width / canvas.height, z-RADIUS-1, z+RADIUS+500)
    program.setUniformMatrix('u_ProjMatrix', proj.array())
    pvm = proj.multiply(view).multiply(model)
  
  octahedron.draw = -> 
    octahedron.activate()
    tessellate()
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
    #$('#overlay').text("z: #{z.toFixed(2)}, deltaY: #{e.deltaY}, to surface: #{(z-RADIUS).toFixed(2)}")
    
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