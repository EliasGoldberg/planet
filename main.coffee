$ ->
  gl = document.getElementById('gl').getContext('webgl')
  gl.enable(gl.DEPTH_TEST)
  gl.enable(gl.CULL_FACE);
  gl.clearColor(0.5,0.6,0.7,1.0)
  gl.getExtension('OES_standard_derivatives');
  
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
      gl_FragColor = vec4(mix(vec3(0.0), vec3(0.7, 0.6, 0.5), edgeFactor()),1.0);
      //gl_FragColor = vec4(0.7, 0.6, 0.5, 1.0);
    }
  ''')
    
  program.activate()

  view = Matrix.lookAt([0, 2, 7],[0,0,0],[0,1,0])
  proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, 1, 100)
  program.setUniformMatrix('u_ProjMatrix', proj.array())
  program.setUniformMatrix('u_ViewMatrix', view.array())

  octahedron = new Model(gl,program)

  octahedron.addFaces([
    new Face(new Vector([0, 1,0]), new Vector([ 0,0, 1]), new Vector([ 1,0, 0])),  # 0
    new Face(new Vector([0, 1,0]), new Vector([-1,0, 0]), new Vector([ 0,0, 1])),  # 1
    new Face(new Vector([0, 1,0]), new Vector([ 0,0,-1]), new Vector([-1,0, 0])),  # 2
    new Face(new Vector([0, 1,0]), new Vector([ 1,0, 0]), new Vector([ 0,0,-1]))   # 3
  ])

  octahedron.addFaces([
    new Face(new Vector([0,-1,0]), new Vector([ 1,0, 0]), new Vector([ 0,0, 1])),  # 4
    new Face(new Vector([0,-1,0]), new Vector([ 0,0, 1]), new Vector([-1,0, 0])),  # 5
    new Face(new Vector([0,-1,0]), new Vector([-1,0, 0]), new Vector([ 0,0,-1])),  # 6
    new Face(new Vector([0,-1,0]), new Vector([ 0,0,-1]), new Vector([ 1,0, 0]))   # 7
  ])

  octahedron.animate = (elapsed) ->
    model = Matrix.rotation(elapsed * 0.1 % 360, 0,1,0)
    program.setUniformMatrix('u_ModelMatrix', model.array())
  octahedron.draw = -> gl.drawElements(gl.TRIANGLES, octahedron.indices.length, gl.UNSIGNED_BYTE, 0)

  engine = new Engine(gl)
  engine.addModel(octahedron)
  engine.start()

midpoint = (a, b) -> [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2, (a[2] + b[2]) / 2]

ubc = (a, b) -> if a is 0 and b is 0 then 1 else 0
uniqueBary = (a, b) ->
  [ubc(a[3],b[3]), ubc(a[4],b[4]), ubc(a[5],b[5])]

tessellate = (data,face) ->
  indices = data.indices[face*3..face*3+2]
  v0 = data.vertices[indices[0]*data.stride .. indices[0]*data.stride+data.stride - 1]
  v1 = data.vertices[indices[1]*data.stride .. indices[1]*data.stride+data.stride - 1]
  v2 = data.vertices[indices[2]*data.stride .. indices[2]*data.stride+data.stride - 1]

  m0 = new Vector(midpoint(v0, v1)).normalize().elements().concat(uniqueBary(v0,v1))
  m1 = new Vector(midpoint(v1, v2)).normalize().elements().concat(uniqueBary(v1,v2))
  m2 = new Vector(midpoint(v2, v0)).normalize().elements().concat(uniqueBary(v2,v0))

  newVertices = data.vertices.slice(0)
  newIndices = data.indices.slice(0)
  mi0 = newVertices.length / data.stride
  mi1 = mi0 + 1
  mi2 = mi1 + 1

  newVertices = newVertices.concat(m0)
  newVertices = newVertices.concat(m1)
  newVertices = newVertices.concat(m2)

  newIndices[face*3 + 1] = mi0
  newIndices[face*3 + 2] = mi2

  newIndices.push(mi0)
  newIndices.push(indices[1])
  newIndices.push(mi1)

  newIndices.push(mi0)
  newIndices.push(mi1)
  newIndices.push(mi2)

  newIndices.push(mi2)
  newIndices.push(mi1)
  newIndices.push(indices[2])

  newPointers = []
  for p in data.pointers
    newPointers.push({name: p.name, dim: p.dim, offset: p.offset})