describe "ShaderProgram", ->
  gl = null
  canvas = document.createElement('canvas')
  document.body.appendChild(canvas)
  canvas.width  = 300
  canvas.height = 200
  canvas.style.width  = 300  + "px"
  canvas.style.height = 200 + "px"

  it "should have access to a valid gl context", ->
    gl = canvas.getContext('webgl2')
    expect(gl.getError()).toBe(gl.NO_ERROR)

  it "should create a program when initialized with a gl context", ->
    program = new ShaderProgram(gl)
    expect(gl.getError()).toBe(0)
    expect(program.id).toBeDefined()

  it "should log an error if asked to attach an invalid shader", ->
    spyOn(console, 'log')
    program = new ShaderProgram(gl)
    program.addShader(gl.VERTEX_SHADER,'moid vain() { this is not a valid shader; }')
    expect(console.log.calls.mostRecent().args[0]).toMatch(/ERROR/)

  it "should compile and attach a valid shader with no errors", ->
    spyOn(console, 'log')
    program = new ShaderProgram(gl)
    program.addShader(gl.VERTEX_SHADER,'void main() { gl_Position = vec4(0, 0, 0, 1); }')
    expect(console.log).not.toHaveBeenCalled()
    shaders = gl.getAttachedShaders(program.id)
    expect(shaders.length).toBe(1)

  it "should link the shader programs when activated", ->
    spyOn(console, 'log')
    program = new ShaderProgram(gl)
    program.addShader(gl.VERTEX_SHADER,'void main() { gl_Position = vec4(0, 0, 0, 1); }')
    program.addShader(gl.FRAGMENT_SHADER,'void main() { gl_FragColor = vec4(1, 1, 1, 1); }')

    shaders = gl.getAttachedShaders(program.id)
    expect(shaders.length).toBe(2)

    program.activate()
    expect(console.log).not.toHaveBeenCalled()
