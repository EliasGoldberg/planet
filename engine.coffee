class @Engine
  constructor: (@gl) ->
    @models = []
    @startTime = null
    @gl.clearColor(0.0,0.0,0.0,1.0)

  addModel: (model) -> @models.push(model)

  tick: =>
    elapsed = Date.now() - @startTime
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    for model in @models
      model.animate(elapsed)
      model.draw()
    requestAnimationFrame(this.tick)

  start: ->
    @startTime = Date.now()
    this.tick()