$ ->
  gl = document.getElementById('gl').getContext('webgl')

  program = new ShaderProgram(gl)

  program.addShader(gl.VERTEX_SHADER,'''
      attribute vec4 a_Position;
      attribute vec4 a_Color;
      uniform mat4 u_ViewMatrix;
      uniform mat4 u_ProjMatrix;
      varying vec4 v_Color;
      void main() {
        gl_Position = u_ProjMatrix * u_ViewMatrix * a_Position;
        v_Color = a_Color;
      }
    ''')

  program.addShader(gl.FRAGMENT_SHADER,'''
      precision mediump float;
      varying vec4 v_Color;
      void main() {
        gl_FragColor = v_Color;
      }
    ''')
    
  program.activate()

  vertices = {
    data: [ 0.75,  1.0, -4.0, 0.4, 1.0, 0.4,        # green right back
            0.25, -1.0, -4.0, 0.4, 1.0, 0.4,
            1.25, -1.0, -4.0, 1.0, 0.4, 0.4,
            
            0.75,  1.0, -2.0, 1.0, 1.0, 0.4,        # yellow right middle
            0.25, -1.0, -2.0, 1.0, 1.0, 0.4,
            1.25, -1.0, -2.0, 1.0, 0.4, 0.4,
            
            0.75,  1.0, 0.0, 0.4, 0.4, 1.0,         # blue right front
            0.25, -1.0, 0.0, 0.4, 0.4, 1.0,
            1.25, -1.0, 0.0, 1.0, 0.4, 0.4,
            
           -0.75,  1.0, -4.0, 0.4, 1.0, 0.4,        # green left back
           -1.25, -1.0, -4.0, 0.4, 1.0, 0.4,
           -0.25, -1.0, -4.0, 1.0, 0.4, 0.4,
            
           -0.75,  1.0, -2.0, 1.0, 1.0, 0.4,        # yellow left middle
           -1.25, -1.0, -2.0, 1.0, 1.0, 0.4,
           -0.25, -1.0, -2.0, 1.0, 0.4, 0.4,
            
           -0.75,  1.0, 0.0, 0.4, 0.4, 1.0,         # blue left front
           -1.25, -1.0, 0.0, 0.4, 0.4, 1.0,
           -0.25, -1.0, 0.0, 1.0, 0.4, 0.4]
    stride: 6
    pointers: 
      [ {name: 'a_Position', dim: 3, offset: 0}
        {name: 'a_Color',    dim: 3, offset: 3} ]
    uniforms: []
    textures: []
  }
  model = new Model(vertices,gl,program)

  near = 1.0; far = 10.0
  model.animate = (elapsed) ->
    view = Matrix.lookAt([0, 0, 5],[0,0,-100],[0,1,0])
    proj = Matrix.perspective(30, gl.canvas.clientWidth  / gl.canvas.clientHeight, near, far)
    program.setUniformMatrix('u_ProjMatrix', proj.array())
    program.setUniformMatrix('u_ViewMatrix', view.array())

  document.onkeydown = (ev) ->
    switch ev.keyCode
      when 39 then near += 1
      when 37 then near -= 1
      when 38 then far  += 1
      when 40 then far  -= 1
    $('#msg').html("near: #{near} far: #{far}")

  model.draw = -> gl.drawArrays(gl.TRIANGLES, 0, 18)

  engine = new Engine(gl)
  engine.addModel(model)
  engine.start()
