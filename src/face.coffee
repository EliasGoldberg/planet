class @Face
  constructor: (v0,v1,v2,lvl) ->
    RADIUS = 6370000
    @v = [v0,v1,v2]
    @b = [[1,0,0],[0,1,0],[0,0,1]]
    @centroid = this.getCentroid()
    @children = []
    @level = if lvl? then lvl else 0
    @isUpsidedown = 0
    @divideDistance = v0.distance(v1) * 5
    @string = "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"
    @id = -1
    @normedVectors = [v0.normalize().scale(RADIUS), v1.normalize().scale(RADIUS), v2.normalize().scale(RADIUS)]
    @patchedVectors = []

  getLeafFaces: () ->
    leaves = []
    if (@children.length is 4)
      for child in @children
        leaves = leaves.concat(child.getLeafFaces())
    else
      leaves.push(this)
    leaves

  getPossiblePatches: (camera,patch,model,radius,parentInstance,metrics) ->
    possiblePatches = []
    stats = this.getAABBDistanceAndSize(camera, model, patch, radius, parentInstance, metrics)
    score = stats.distance / stats.size
    if score < 6
      if @children.length == 4
        for child in @children
          results = child.getPossiblePatches(camera,patch,model,radius,parentInstance, metrics)
          t1 = new Date().getTime()
          possiblePatches = possiblePatches.concat(results)
          t2 = new Date().getTime()
          metrics.concat += (t2 - t1)
        possiblePatches
      else
        [{parentInstance: parentInstance, id: @id, score: score}]
    else
      []

  getAABBDistanceAndSize: (camera, model, patch, radius, parentInstance, metrics) ->
    aabb = this.getAABB(model, patch, radius, parentInstance, metrics)
    dx = Math.max(aabb.min.a[0] - camera.a[0], 0, camera.a[0] - aabb.max.a[0]);
    dy = Math.max(aabb.min.a[1] - camera.a[1], 0, camera.a[1] - aabb.max.a[1]);
    dz = Math.max(aabb.min.a[2] - camera.a[2], 0, camera.a[2] - aabb.max.a[2]);
    t1 = new Date().getTime()
    r = {distance: Math.sqrt(dx*dx + dy*dy + dz*dz), size: aabb.max.a[0] - aabb.min.a[0]}
    t2 = new Date().getTime()
    metrics.dist += (t2 - t1)
    r

  getAABB: (model, patch, radius, parentInstance, metrics) ->
    max = new Vector([-Infinity,-Infinity,-Infinity])
    min = new Vector([Infinity,Infinity,Infinity])
    for vector,i in @normedVectors
      t2 = new Date().getTime()
      if not @patchedVectors[parentInstance]? then @patchedVectors[parentInstance] = []
      if not @patchedVectors[parentInstance][i]? then @patchedVectors[parentInstance][i] = patch.multiply(vector)
      patchedVector = @patchedVectors[parentInstance][i]
      t3 = new Date().getTime()
      transformedVector = model.multiply(patchedVector)
      t5 = new Date().getTime()
      metrics.patch += (t3-t2)
      metrics.trans += (t5-t3)
      for i in [0..2]
        if transformedVector.a[i] < min.a[i] then min.a[i] = transformedVector.a[i]
        if transformedVector.a[i] > max.a[i] then max.a[i] = transformedVector.a[i]
    { min: min, max: max }

  getCentroid: () ->
    return new Vector([(@v[0].a[0] + @v[1].a[0] + @v[2].a[0])/3,
                      (@v[0].a[1] + @v[1].a[1] + @v[2].a[1])/3,
                      (@v[0].a[2] + @v[1].a[2] + @v[2].a[2])/3])

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


  getNormal: (pvm) ->
    v1 = pvm.multiply(@v[1]).minus(pvm.multiply(@v[0]))
    v2 = pvm.multiply(@v[2]).minus(pvm.multiply(@v[0]))
    v1.crossProduct(v2).normalize()
  
  isBackFacing: (camera,pvm) ->
    normal = this.getNormal(pvm)
    cVec = new Vector([0,0,0]).minus(camera).normalize()
    dot = normal.dotProduct(cVec)
    dot > 0

  setBary: (bary,i) -> @b[i] = bary
  setBarys: (barys) -> @b = barys

  midpoint: (a, b) -> [(a.a[0] + b.a[0]) / 2, (a.a[1] + b.a[1]) / 2, (a.a[2] + b.a[2]) / 2]

  toString: () -> @string