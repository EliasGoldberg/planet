class @Face
  constructor: (v0,v1,v2,lvl) ->
    RADIUS = 6370000
    #RADIUS = 10
    @v = [v0,v1,v2]
    @b = [[1,0,0],[0,1,0],[0,0,1]]
    @centroid = this.getCentroid()
    @children = []
    @level = if lvl? then lvl else 0
    @isUpsidedown = 0
    @string = "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"
    @id = -1
    @normedVectors = [v0.normalize().scale(RADIUS), v1.normalize().scale(RADIUS), v2.normalize().scale(RADIUS)]

  getLeafFaces: () ->
    leaves = []
    if (@children.length is 4)
      for child in @children
        leaves = leaves.concat(child.getLeafFaces())
    else
      leaves.push(this)
    leaves

  getPossiblePatches: (camera,patch,model,proj,view,width,height) ->
    possiblePatches = []

    patchVertices = this.buildPatchVertices(patch)
    transformedVertices = this.buildTranformVertices(patchVertices,model)

    if @children.length == 0
      angle = this.normalAngle(camera, transformedVertices)
      isFacingAway = angle < 0
      if isFacingAway then return []

    screenVertices = this.getScreenVertices(patchVertices, model, view, proj, width, height);
    area = this.getScreenArea(screenVertices)
    
    if area > 500
      if @children.length == 4
        for child in @children
          results = child.getPossiblePatches(camera,patch,model,proj,view,width,height)
          possiblePatches = possiblePatches.concat(results)
        possiblePatches
      else
        [{id: @id}]
    else
      []

  getScreenVertices: (patchVertices, model, view, proj, width, height) ->
    screenVertices = []
    for vert,i in patchVertices
      vertex = vert.screen(proj, view, model, width, height)
      screenVertices.push(vertex)
    screenVertices

  getScreenArea: (screenPoints) ->
    a = screenPoints[0]; b = screenPoints[1]; c = screenPoints[2]
    ab = a.distance(b); ac = a.distance(c); bc = b.distance(c);
    p = (ab + ac + bc) / 2
    Math.sqrt(p * (p-ab) * (p-ac) * (p-bc))

  buildPatchVertices: (patchMatrix) ->
    patchedVertices = []
    for vector,i in @normedVectors
      patchedVertices[i] = patchMatrix.multiply(vector)
    patchedVertices;

  buildTranformVertices: (patchVertices, model) ->
    transformedVertices = []
    for patchedVertex in patchVertices
      transformedVertices.push(model.multiply(patchedVertex))
    transformedVertices

  getCentroid: () ->
    return new Vector([(@v[0].a[0] + @v[1].a[0] + @v[2].a[0])/3,
                      (@v[0].a[1] + @v[1].a[1] + @v[2].a[1])/3,
                      (@v[0].a[2] + @v[1].a[2] + @v[2].a[2])/3])

  getNormedCentroid: () ->
    return new Vector([(@normedVectors[0].a[0] + @normedVectors[1].a[0] + @normedVectors[2].a[0])/3,
                      (@normedVectors[0].a[1] + @normedVectors[1].a[1] + @normedVectors[2].a[1])/3,
                      (@normedVectors[0].a[2] + @normedVectors[1].a[2] + @normedVectors[2].a[2])/3])

  tessellate: (subdivisions,midpointFunction,lvl) ->
    if subdivisions is 0 then return [this]
    if not midpointFunction? then midpointFunction = Vector.lerp
    if not lvl? then lvl = 0

    m0 = midpointFunction(@v[0], @v[1], 0.5)
    b0 = Vector.nor @b[0], @b[1]
    m1 = midpointFunction(@v[1], @v[2], 0.5)
    b1 = Vector.nor @b[1], @b[2]
    m2 = midpointFunction(@v[2], @v[0], 0.5)
    b2 = Vector.nor @b[2], @b[0]

    f0 = new Face(@v[0], m0, m2, @level+1)
    f0.setBarys([ @b[0], b0, b2])
    f0.isUpsidedown = @isUpsidedown

    f1 = new Face(m0,@v[1], m1, @level+1)
    f1.setBarys([ b0, @b[1], b1])
    f1.isUpsidedown = @isUpsidedown

    f2 = new Face(m0,m1,m2, @level+1)
    f2.setBarys([b0,b1,b2])
    f2.isUpsidedown = if @isUpsidedown == 1 then 0 else 1

    f3 = new Face(m2,m1,@v[2], @level+1)
    f3.setBarys([b2,b1,@b[2]])
    f3.isUpsidedown = @isUpsidedown

    @children = [f0,f1,f2,f3]

    results = [].concat(f0.tessellate(subdivisions-1,midpointFunction,lvl+1))
    .concat(f1.tessellate(subdivisions-1,midpointFunction,lvl+1))
    .concat(f2.tessellate(subdivisions-1,midpointFunction,lvl+1))
    .concat(f3.tessellate(subdivisions-1,midpointFunction,lvl+1))

    if lvl is 0
      for result,i in results
        result.id = i
    results

  getNormal: (transformedVectors) ->
    if !transformedVectors? then transformedVectors = @v
    v1 = transformedVectors[1].minus(transformedVectors[0])
    v2 = transformedVectors[2].minus(transformedVectors[0])
    v1.crossProduct(v2).normalize()

  normalAngle: (camera,transformedVectors) ->
    normal = this.getNormal(transformedVectors)
    cVec = camera.normalize()
    normal.dotProduct(cVec)

  setBary: (bary,i) -> @b[i] = bary
  setBarys: (barys) -> @b = barys

  midpoint: (a, b) -> [(a.a[0] + b.a[0]) / 2, (a.a[1] + b.a[1]) / 2, (a.a[2] + b.a[2]) / 2]

  toString: () -> @string
