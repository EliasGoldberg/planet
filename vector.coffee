class @Vector
  constructor: (@a) ->
  array: -> new Float32Array(@a)
  elements: -> @a

  normalize: ->
    rlf = 1 / Math.sqrt(@a[0]*@a[0] + @a[1]*@a[1] + @a[2]*@a[2])
    new Vector([@a[0]*rlf, @a[1]*rlf, @a[2]*rlf])

  crossProduct: (n) ->
    b = n.elements()
    x = @a[1] * b[2] - @a[2] * b[1]
    y = @a[2] * b[0] - @a[0] * b[2]
    z = @a[0] * b[1] - @a[1] * b[0]
    new Vector([x,y,z])

  minus: (n) ->
    b = n.elements()
    new Vector([@a[0] - b[0], @a[1] - b[1], @a[2] - b[2]])

  @nor: (a,b) -> [ not (a[0] or b[0]), not (a[1] or b[1]), not (a[2] or b[2]) ]

  toString: -> "#{@a[0]}, #{@a[1]}, #{@a[2]}"
