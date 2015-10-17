class @Face
  constructor: (v0,v1,v2,lvl) ->
    @v = [v0,v1,v2]
    @b = []
    @centroid = this.getCentroid()
    @children = []
    @level = if lvl? then lvl else 0
    @divideDistance = v0.distance(v1) * 5

  detail: (pvm,camera,results) ->
    if not results? then results = { remove: [], add: [] }
    tranformedCentroid = pvm.multiply(@centroid)
    d = camera.distance(tranformedCentroid)
    if d < @divideDistance
      if @children.length is 0
        results.remove.push(this)
        results.add = results.add.concat(this.tessellate(1,Vector.slerp))
      else
        for child in @children
          child.detail(pvm,camera,results)
    else
      if @children.length is 4
        results.add.push(this)
        for child in @children
          results.remove = results.remove.concat(child.getLeafFaces())
        @children = []


  getLeafFaces: () ->
    leaves = []
    if (@children.length is 4)
      for child in @children
        leaves = leaves.concat(child.getLeafFaces())
    else
      leaves.push(this)
    leaves


  getCentroid: () ->
    return new Vector([(@v[0].a[0] + @v[1].a[0] + @v[2].a[0])/3,
                      (@v[0].a[1] + @v[1].a[1] + @v[2].a[1])/3,
                      (@v[0].a[2] + @v[1].a[2] + @v[2].a[2])/3])

  tessellate: (subdivisions,midpointFunction) ->
    if subdivisions is 0 then return [this]
    if not midpointFunction? then midpointFunction = Vector.lerp

    m0 = midpointFunction(@v[0], @v[1], 0.5)
    b0 = Vector.nor @b[0], @b[1]
    m1 = midpointFunction(@v[1], @v[2], 0.5)
    b1 = Vector.nor @b[1], @b[2]
    m2 = midpointFunction(@v[2], @v[0], 0.5)
    b2 = Vector.nor @b[2], @b[0]

    f0 = new Face(@v[0], m0, m2, @level+1)
    f0.setBarys([ @b[0], b0, b2])
    f1 = new Face(m0,@v[1], m1, @level+1)
    f1.setBarys([ b0, @b[1], b1])
    f2 = new Face(m0,m1,m2, @level+1)
    f2.setBarys([b0,b1,b2])
    f3 = new Face(m2,m1,@v[2], @level+1)
    f3.setBarys([b2,b1,@b[2]])
    @children = [f0,f1,f2,f3]

    [].concat(f0.tessellate(subdivisions-1,midpointFunction))
    .concat(f1.tessellate(subdivisions-1,midpointFunction))
    .concat(f2.tessellate(subdivisions-1,midpointFunction))
    .concat(f3.tessellate(subdivisions-1,midpointFunction))

  setBary: (bary,i) -> @b[i] = bary
  setBarys: (barys) -> @b = barys

  midpoint: (a, b) -> [(a.a[0] + b.a[0]) / 2, (a.a[1] + b.a[1]) / 2, (a.a[2] + b.a[2]) / 2]

  toString: () -> "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"