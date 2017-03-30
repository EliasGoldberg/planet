class @Vector
  constructor: (@a) -> @string = "#{@a[0].toFixed(4)}, #{@a[1].toFixed(4)}, #{@a[2].toFixed(4)}"
  array: -> new Float32Array(@a)
  elements: -> @a

  length: ->
    Math.sqrt(@a[0]*@a[0] + @a[1]*@a[1] + @a[2]*@a[2])

  normalize: ->
    rlf = 1 / this.length()
    new Vector([@a[0]*rlf, @a[1]*rlf, @a[2]*rlf])

  crossProduct: (v) ->
    b = v.elements()
    x = @a[1] * b[2] - @a[2] * b[1]
    y = @a[2] * b[0] - @a[0] * b[2]
    z = @a[0] * b[1] - @a[1] * b[0]
    new Vector([x,y,z])

  dotProduct: (v) -> (@a[i] * v.a[i] for i in [0..2]).reduce((p,c,i,a) -> p + c)

  minus: (v) ->
    b = v.elements()
    new Vector([@a[0] - b[0], @a[1] - b[1], @a[2] - b[2]])

  add: (v) ->
    b = v.elements()
    new Vector([@a[0] + b[0], @a[1] + b[1], @a[2] + b[2]])

  @nor: (a,b) -> [ +not (a[0] or b[0]), +not (a[1] or b[1]), +not (a[2] or b[2]) ]

  @g: ->
   ((Math.random() + Math.random() + Math.random() + Math.random() +
     Math.random() + Math.random()) - 3) / 3;

  @gauss: ->
    new Vector([@g(), @g(), @g()]).normalize()

  @random: ->
    new Vector([Math.random()*2-1,Math.random()*2-1,Math.random()*2-1]).normalize()

  @lerp: (a,b,t) ->
    new Vector([
      a.a[0] + (b.a[0] - a.a[0]) * t,
      a.a[1] + (b.a[1] - a.a[1]) * t,
      a.a[2] + (b.a[2] - a.a[2]) * t])

  @slerp: (a,b,t) ->
    o = Math.acos(a.dotProduct(b))
    a.scale(Math.sin((1-t)*o) / Math.sin(o)).add(b.scale(Math.sin(t*o) / Math.sin(o)))

  distance: (v) ->
    return Math.sqrt(Math.pow(v.a[0] - @a[0], 2) +
                     Math.pow(v.a[1] - @a[1], 2) +
                     Math.pow(v.a[2] - @a[2], 2))

  scale: (n) -> new Vector([@a[0]*n,@a[1]*n,@a[2]*n])

  cols: () -> [[@a[0],@a[1],@a[2],1]]

  screen: (proj, view, model, width, height) ->
    projView = proj.multiply(view)
    modelVert = model.multiply(this)
    m = projView.m; x = modelVert.a[0]; y = modelVert.a[1]; z = modelVert.a[2]
    d = 1 / (m[3] * x + m[7] * y + m[11] * z + m[15])
    hWidth = width / 2
    hHeight = height / 2
    new Vector([
      ((m[0]*x + m[4] * y + m[8] * z + m[12]) * d * hWidth) + hWidth,
      ((m[1]*x + m[5] * y + m[9] * z + m[13]) * d * hHeight) + hHeight,
      (m[2]*x + m[6] * y + m[10]* z + m[14]) * d
    ])

  toString: -> @string
