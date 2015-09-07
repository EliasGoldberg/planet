$ ->
  canvas = setCanvasSize()
  gl = canvas.getContext('webgl')
  gl.enable(gl.DEPTH_TEST)
  gl.enable(gl.CULL_FACE);
  gl.clearColor(0.0,0.0,0.0,1.0)
  gl.getExtension('OES_standard_derivatives')

  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
    attribute vec4 a_Position;
    attribute vec3 a_Bary;
    varying vec3 v_Bary;
    uniform mat4 u_ModelMatrix;
    uniform mat4 u_ViewMatrix;
    uniform mat4 u_ProjMatrix;
    void main() {
      gl_Position = u_ProjMatrix * u_ViewMatrix * u_ModelMatrix * a_Position;
      v_Bary = a_Bary;
    }
  ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
    #extension GL_OES_standard_derivatives : enable
    precision mediump float;
    varying vec3 v_Bary;

    float edgeFactor(){
      vec3 d = fwidth(v_Bary);
      vec3 a3 = smoothstep(vec3(0.0), 1.5*d, v_Bary);
      return min(min(a3.x, a3.y), a3.z);
    }

    void main() {
      vec3 faceColor = vec3(37.0/255.0, 45.0/255.0, 118.0/255.0);
      vec3 wireColor = vec3(147.0/255.0, 149.0/255.0, 189.0/255.0);
      gl_FragColor = vec4(mix(wireColor, faceColor, edgeFactor()),1.0);
    }
  ''')

  program.activate()

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

  for face in octaFaces
    octahedron.removeFaces([face])
    smallerFaces = face.tessellate(3)
    octahedron.addFaces(smallerFaces)

  diffX = 0
  diffY = 0
  dragging = false
  x = 0
  y = 0
  rX = 0
  rY = 0
  z = 7
  octahedron.animate = (elapsed) ->
    rX += if dragging? and dragging then diffX else 0
    rY += if dragging? and dragging then diffY else 0
    model = Matrix.rotation(-rX * 0.4 % 360, 0,1,0).multiply(
      Matrix.rotation(-rY * 0.4 % 360, 1,0,0))
    program.setUniformMatrix('u_ModelMatrix', model.array())
    view = Matrix.lookAt([0, 0, z],[0,0,0],[0,1,0])
    program.setUniformMatrix('u_ViewMatrix', view.array())

  octahedron.draw = -> gl.drawElements(gl.TRIANGLES, octahedron.indices.length, gl.UNSIGNED_BYTE, 0)

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

  $("#gl").mouseup((e)->
    dragging = false
  )

  $('#gl').mousewheel((e) ->
    console.log(e.deltaX, e.deltaY, e.deltaFactor)
    z += e.deltaY * e.deltaFactor * .01
  )

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

