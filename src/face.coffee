class @Face
  constructor: (v0,v1,v2,lvl) ->
    #RADIUS = 6370000
    RADIUS = 10
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

  getPossiblePatches: (camera,patch,model,proj,view,width,height,parentInstance,r) ->
    if not r then r = 0
    possiblePatches = []
    this.buildPatchVectors(parentInstance,patch)
    if (r == 0 and parentInstance < 8)
      cameraSpaceVertices = this.getCameraSpaceVertices(model, view, proj,width,height,parentInstance);

    transformedVectors = this.buildTranformVectors(parentInstance,model)

    aabb = this.getAABB(transformedVectors)
    if !this.isAABBInsideFrustum(aabb,camera,proj) then return []

    stats = this.getAABBDistanceAndSize(camera, aabb)
    score = stats.distance / stats.size
    if score < 12
      if @children.length == 4
        for child in @children
          results = child.getPossiblePatches(camera,patch,model,proj,view,width,height,parentInstance, r + 1)
          possiblePatches = possiblePatches.concat(results)
        possiblePatches
      else
        [{parentInstance: parentInstance, id: @id, score: score }]
    else
      []

  getCameraSpaceVertices: (model, view, proj, width, height, id) ->
    screenPoints = []

    for vert,i in @normedVectors
      projView = proj.multiply(view)
      modelVert = model.multiply(vert)
      m = projView.m; x = modelVert.a[0]; y = modelVert.a[1]; z = modelVert.a[2]
      d = 1 / (m[3] * x + m[7] * y + m[11] * z + m[15])
      hWidth = width / 2
      hHeight = height / 2
      sp2 = new Vector([
        ((m[0]*x + m[4] * y + m[8] * z + m[12]) * d * hWidth) + hWidth,
        ((m[1]*x + m[5] * y + m[9] * z + m[13]) * d * hHeight) + hHeight,
        (m[2]*x + m[6] * y + m[10]* z + m[14]) * d
      ])

      screenPoints.push(sp2)
      $('#vert-' + id + '-' + i).css({ position:'fixed', color:'white', backgroundColor:'black', left:sp2.a[0] + 'px', bottom:sp2.a[1] + 'px' })
      $('#vert-' + id + '-' + i).text("#{modelVert}")
    screenPoints

  isAABBInsideFrustum: (aabb,camera,proj) ->
    max = aabb.max.minus(camera)
    min = aabb.min.minus(camera)
    rightUpperFront = proj.isPointInFrustum(new Vector([max.a[0], max.a[1], max.a[2]]))
    leftUpperFront =  proj.isPointInFrustum(new Vector([min.a[0], max.a[1], max.a[2]]))
    leftUpperBack =   proj.isPointInFrustum(new Vector([min.a[0], max.a[1], min.a[2]]))
    rightUpperBack =  proj.isPointInFrustum(new Vector([max.a[0], max.a[1], min.a[2]]))

    rightLowerFront = proj.isPointInFrustum(new Vector([max.a[0], min.a[1], max.a[2]]))
    leftLowerFront =  proj.isPointInFrustum(new Vector([min.a[0], min.a[1], max.a[2]]))
    leftLowerBack =   proj.isPointInFrustum(new Vector([min.a[0], min.a[1], min.a[2]]))
    rightLowerBack =  proj.isPointInFrustum(new Vector([max.a[0], min.a[1], min.a[2]]))
    return rightUpperFront or leftUpperFront or leftUpperBack or rightUpperBack or
           rightLowerFront or leftLowerFront or leftLowerBack or rightLowerBack


  getAABBDistanceAndSize: (camera, aabb) ->
    dx = Math.max(aabb.min.a[0] - camera.a[0], 0, camera.a[0] - aabb.max.a[0]);
    dy = Math.max(aabb.min.a[1] - camera.a[1], 0, camera.a[1] - aabb.max.a[1]);
    dz = Math.max(aabb.min.a[2] - camera.a[2], 0, camera.a[2] - aabb.max.a[2]);
    {distance: Math.sqrt(dx*dx + dy*dy + dz*dz), size: aabb.max.a[0] - aabb.min.a[0]}

  getAABB: (transformedVectors) ->
    max = new Vector([-Infinity,-Infinity,-Infinity])
    min = new Vector([Infinity,Infinity,Infinity])
    for transformedVector,i in transformedVectors
      for i in [0..2]
        if transformedVector.a[i] < min.a[i] then min.a[i] = transformedVector.a[i]
        if transformedVector.a[i] > max.a[i] then max.a[i] = transformedVector.a[i]
    { min: min, max: max }

  buildPatchVectors: (parentInstance,patch) ->
    if not @patchedVectors[parentInstance]?
      @patchedVectors[parentInstance] = []
      for vector,i in @normedVectors
        @patchedVectors[parentInstance][i] = patch.multiply(vector)

  buildTranformVectors: (parentInstance,model) ->
    transformedVectors = []
    for patchedVector in @patchedVectors[parentInstance]
      t1 = new Date().getTime()
      transformedVectors.push(model.multiply(patchedVector))
      t2 = new Date().getTime()
    transformedVectors

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
