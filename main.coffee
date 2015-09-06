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
    gl.viewport(0, 0, canvas.width, canvas.height);
    view = Matrix.lookAt([0, 1, 7],[0,0,0],[0,1,0])
    proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
    program.setUniformMatrix('u_ProjMatrix', proj.array())
    program.setUniformMatrix('u_ViewMatrix', view.array())

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

  octahedron.animate = (elapsed) ->
    model = Matrix.rotation(elapsed * 0.1 % 360, 0,1,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  octahedron.draw = -> gl.drawElements(gl.TRIANGLES, octahedron.indices.length, gl.UNSIGNED_BYTE, 0)

  engine = new Engine(gl)
  engine.addModel(octahedron)
  engine.start()

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

midpoint = (a, b) -> [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2, (a[2] + b[2]) / 2]

ubc = (a, b) -> if a is 0 and b is 0 then 1 else 0
uniqueBary = (a, b) ->
  [ubc(a[3],b[3]), ubc(a[4],b[4]), ubc(a[5],b[5])]

