$ ->
  canvas = document.getElementById('gl')
  gl = canvas.getContext('webgl')

  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute vec2 a_TexCoord;
      varying vec2 v_TexCoord;
      uniform mat4 u_ModelMatrix;
      void main() {
        gl_Position = u_ModelMatrix * a_Position;
        v_TexCoord = a_TexCoord;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      precision mediump float;
      uniform sampler2D u_Sampler0;
      uniform sampler2D u_Sampler1;
      varying vec2 v_TexCoord;
      void main() {
        vec4 color0 = texture2D(u_Sampler0, v_TexCoord);
        vec4 color1 = texture2D(u_Sampler1, v_TexCoord);
        gl_FragColor = color0 * color1;
      }
    ''')

  program.activate()

  vertices =
    data: [-0.5,  0.5, 0.0, 1.0,
           -0.5, -0.5, 0.0, 0.0,
            0.5,  0.5, 1.0, 1.0,
            0.5, -0.5, 1.0, 0.0 ]
    stride: 4
    pointers:[
      {name: 'a_Position', dim: 2, offset: 0},
      {name: 'a_TexCoord', dim: 2, offset: 2}]
    uniforms:[]
    textures:[
      {url: 'sky.JPG',    sampler:'u_Sampler0'},
      {url: 'circle.gif', sampler:'u_Sampler1'}]

  model = new Model(vertices,gl,program)

  model.animate = (elapsed) ->
    angle = (45 * elapsed / 1000.0) % 360
    m = Matrix.rotation(angle,0,0,1).translate(0.35,0,0)
    program.setUniformMatrix 'u_ModelMatrix', m.array()

  model.draw = -> gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  engine = new Engine(gl)
  engine.addModel(model)
  engine.start()