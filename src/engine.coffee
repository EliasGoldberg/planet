class @Engine
  constructor: (@gl) ->
    @models = []
    @lastFrameStartTime = 0
    @framesPerSecond = 0
    @lastSecondTime = 0
  addModel: (model) -> @models.push(model)

  tick: =>
    newFrameStartTime = new Date().getTime()
    timeBetweenFrames = newFrameStartTime - @lastFrameStartTime
    runningTime = newFrameStartTime - @lastSecondTime

    if runningTime >= 1000
      $('#overlay').text(@frameCount)
      @frameCount = 0
      @lastSecondTime = newFrameStartTime

    @lastFrameStartTime = newFrameStartTime
    @frameCount += 1

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    for model in @models
      model.animate(timeBetweenFrames)
      model.draw()

    requestAnimationFrame(this.tick)

  start: ->
    @lastFrameStartTime = new Date().getTime()
    @lastSecondTime = @lastFrameStartTime
    this.tick()
