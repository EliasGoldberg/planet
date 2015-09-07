class @Face
  constructor: (v0,v1,v2) ->
    @v = [v0,v1,v2]
    @b = []

  tessellate: (c) ->
    if c is 0 then return [this]

    m0 = new Vector(this.midpoint(@v[0], @v[1]))
    b0 = Face.uniqueBary(@b[0], @b[1])
    m1 = new Vector(this.midpoint(@v[1], @v[2]))
    b1 = Face.uniqueBary(@b[1], @b[2])
    m2 = new Vector(this.midpoint(@v[2], @v[0]))
    b2 = Face.uniqueBary(@b[2], @b[0])

    f0 = new Face(@v[0], m0, m2)
    f0.setBarys([ @b[0], b0, b2])
    f1 = new Face(m0,@v[1], m1)
    f1.setBarys([ b0, @b[1], b1])
    f2 = new Face(m0,m1,m2)
    f2.setBarys([b0,b1,b2])
    f3 = new Face(m2,m1,@v[2])
    f3.setBarys([b2,b1,@b[2]])

    [].concat(f0.tessellate(c-1))
    .concat(f1.tessellate(c-1))
    .concat(f2.tessellate(c-1))
    .concat(f3.tessellate(c-1))

  setBary: (bary,i) -> @b[i] = bary
  setBarys: (barys) -> @b = barys
  midpoint: (a, b) -> [(a.a[0] + b.a[0]) / 2, (a.a[1] + b.a[1]) / 2, (a.a[2] + b.a[2]) / 2]

  toString: () -> "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"

  @uniqueBary: (a, b) -> [Face.ubc(a[0],b[0]), Face.ubc(a[1],b[1]), Face.ubc(a[2],b[2])]
  @ubc: (a, b) -> if a is 0 and b is 0 then 1 else 0