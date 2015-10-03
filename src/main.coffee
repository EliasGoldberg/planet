$ ->
  Math.seedrandom('goldberg')
  canvas = setCanvasSize()
  gl = canvas.getContext('webgl')
  gl.enable(gl.DEPTH_TEST)
  gl.enable(gl.CULL_FACE);
  gl.clearColor(0.0,0.0,0.1,1.0)
  gl.getExtension('OES_standard_derivatives')

  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
    #define M_PI 3.1415926535897932384626433832795
    attribute vec4 a_Position;
    attribute vec3 a_Bary;
    varying vec3 v_Bary;
    varying highp vec4 v_Pos;
    uniform mediump mat4 u_ModelMatrix;
    uniform mediump mat4 u_ViewMatrix;
    uniform mediump mat4 u_ProjMatrix;
    uniform mediump vec3 featurePoints[20];
    uniform float plateElevations[20];

    int nearest(vec4 pos) {
      int near_idx = 0;
      float d = 1000.0;
      for (int i = 0; i < 20; i++) {
        float current = acos(dot(vec3(pos.xyz),featurePoints[i])) / M_PI * 3.0;
        if (current < d) {
            d = current;
            near_idx = i;
        }
      }
      return near_idx;
    }

    void main() {
      //int i = nearest(a_Position);
      //vec4 pos = vec4(a_Position.xyz * plateElevations[i], 1.0);
      gl_Position = u_ProjMatrix * u_ViewMatrix * u_ModelMatrix * a_Position;
      v_Bary = a_Bary;
      v_Pos = a_Position;
    }
  ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
    #extension GL_OES_standard_derivatives : enable
    #define M_PI 3.1415926535897932384626433832795
    precision mediump float;
    varying vec3 v_Bary;
    varying highp vec4 v_Pos;
    uniform mediump vec3 featurePoints[20];

    float edgeFactor(){
      vec3 d = fwidth(v_Bary);
      vec3 a3 = smoothstep(vec3(0.0), 1.25*d, v_Bary);
      return min(min(a3.x, a3.y), a3.z);
    }

    vec2 nearest(vec4 pos) {
      float d = 1000.0;
      float d2 = 1000.0;
      for (int i = 0; i < 20; i++) {
        float current = acos(dot(vec3(pos.xyz),featurePoints[i])) / M_PI * 3.0;
        if (current < d) {
            d2 = d;
            d = current;
        } else if (current < d2) {
            d2 = current;
        }
      }
      return vec2(d,d2);
    }

    void main() {
      //vec2 near = nearest(v_Pos);
      //float c = min(1.0,near[1] - near[0]);
      vec3 faceColor = vec3(0.8,0.8,0.8);
      vec3 wireColor = vec3(0, 0, 0);
      gl_FragColor = vec4(mix(wireColor, faceColor, edgeFactor()),1);
      //gl_FragColor = vec4(faceColor,1.0);
    }
  ''')

  featurePoints = (Vector.random().elements() for i in [0..19])
  featurePoints = [].concat.apply([], featurePoints)
  plateElevations = (1 + Math.random() * 0.025 for i in [0..19])

  program.activate()

  program.setUniformVectorArray('featurePoints',featurePoints)
  program.setUniformArray('plateElevations',plateElevations)

  setSize = ->
    gl.viewport(0, 0, canvas.width, canvas.height)
    proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
    program.setUniformMatrix('u_ProjMatrix', proj.array())

  setSize()

  $(window).resize(->
    setCanvasSize()
    setSize()
  )

  octahedron = new Model(gl,program)
  octaFaces = [ new Face(new Vector([0, 1,0]), new Vector([ 0, 0, 1]), new Vector([ 1, 0, 0])),  # 0
                new Face(new Vector([0, 1,0]), new Vector([-1, 0, 0]), new Vector([ 0, 0, 1])),  # 1
                new Face(new Vector([0, 1,0]), new Vector([ 0, 0,-1]), new Vector([-1, 0, 0])),  # 2
                new Face(new Vector([0, 1,0]), new Vector([ 1, 0, 0]), new Vector([ 0, 0,-1])),  # 3
                new Face(new Vector([0,-1,0]), new Vector([ 1, 0, 0]), new Vector([ 0, 0, 1])),  # 4
                new Face(new Vector([0,-1,0]), new Vector([ 0, 0, 1]), new Vector([-1, 0, 0])),  # 5
                new Face(new Vector([0,-1,0]), new Vector([-1, 0, 0]), new Vector([ 0, 0,-1])),  # 6
                new Face(new Vector([0,-1,0]), new Vector([ 0, 0,-1]), new Vector([ 1, 0, 0])) ] # 7
  octahedron.addFaces(octaFaces)
  octahedron.removeFaces(octaFaces)
  d = 0
  octahedron.addFaces(face.tessellate(d,Vector.slerp)) for face in octaFaces
  octahedron.applyModifiers()

  diffX = 0
  diffY = 0
  dragging = false
  x = 0
  y = 0
  rX = 0
  rY = 0
  z = 7
  tDist = 5
  octahedron.animate = (elapsed) ->
    rX += if dragging? and dragging then diffX else 0
    rY += if dragging? and dragging then diffY else 0
    model = Matrix.rotation(-rX * 0.4 % 360, 0,1,0).multiply(
      Matrix.rotation(-rY * 0.4 % 360, 1,0,0))
    program.setUniformMatrix('u_ModelMatrix', model.array())
    view = Matrix.lookAt([0, 0, z],[0,0,0],[0,1,0])
    program.setUniformMatrix('u_ViewMatrix', view.array())
    proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
    pvm = proj.multiply(view).multiply(model)
    closeFaces = []
    for face in octaFaces
      f = pvm.multiply(face.centroid)
      c = pvm.multiply(new Vector([0,0,z]))
      d = c.distance(f)
      if (d < tDist) then closeFaces.push(face)


    if (closeFaces.length > 0)
      console.log(d)
      tessFaces = []
      tDist = tDist / 2
      for closeFace in closeFaces
        octaFaces.splice(octaFaces.indexOf(closeFace),1)
        newFaces = closeFace.tessellate(1,Vector.slerp)
        tessFaces = tessFaces.concat(newFaces)
      octaFaces = octaFaces.concat(tessFaces)
      octahedron.removeFaces(closeFaces)
      octahedron.addFaces(tessFaces)

  octahedron.draw = -> gl.drawElements(gl.TRIANGLES, octahedron.indices.length, gl.UNSIGNED_SHORT, 0)

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
  $('#gl').mousewheel (e) -> z += e.deltaY * e.deltaFactor * .01

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

