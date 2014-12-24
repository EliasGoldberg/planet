class @Engine
  constructor: (@gl) ->
    @models = []
    @startTime = null

  addModel: (model) -> @models.push(model)

  tick: =>
    elapsed = Date.now() - @startTime
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    for model in @models
      model.animate(elapsed)
      model.draw()
    requestAnimationFrame(this.tick)

  start: ->
    @startTime = Date.now()
    this.tick()
