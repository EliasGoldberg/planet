class @Engine
  constructor: (@gl) ->
    @models = []
    @startTime = null
    @frame = 0
    @s = 0

  addModel: (model) -> @models.push(model)

  tick: =>
    @frame+=1
    elapsed = Date.now() - @startTime
    
    if (@frame % 100 == 0) 
      e = new Date().getTime() - @s
      $('#overlay').text(1 / (e / 1000 / 100))
      @s = new Date().getTime()
    
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    
    for model in @models
      model.animate(elapsed)
      model.draw()
    requestAnimationFrame(this.tick)

  start: ->
    @startTime = Date.now()
    @s = new Date().getTime()
    this.tick()