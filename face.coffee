class @Face
  constructor: (v1,v2,v3) -> @v = [v1,v2,v3]

  tessellate: (data,face) ->
    indices = data.indices[face*3..face*3+2]
    v0 = data.vertices[indices[0]*data.stride .. indices[0]*data.stride+data.stride - 1]
    v1 = data.vertices[indices[1]*data.stride .. indices[1]*data.stride+data.stride - 1]
    v2 = data.vertices[indices[2]*data.stride .. indices[2]*data.stride+data.stride - 1]

    m0 = new Vector(midpoint(v0, v1)).normalize().elements().concat(uniqueBary(v0,v1))
    m1 = new Vector(midpoint(v1, v2)).normalize().elements().concat(uniqueBary(v1,v2))
    m2 = new Vector(midpoint(v2, v0)).normalize().elements().concat(uniqueBary(v2,v0))

    newVertices = data.vertices.slice(0)
    newIndices = data.indices.slice(0)
    mi0 = newVertices.length / data.stride
    mi1 = mi0 + 1
    mi2 = mi1 + 1

    newVertices = newVertices.concat(m0)
    newVertices = newVertices.concat(m1)
    newVertices = newVertices.concat(m2)

    newIndices[face*3 + 1] = mi0
    newIndices[face*3 + 2] = mi2

    newIndices.push(mi0)
    newIndices.push(indices[1])
    newIndices.push(mi1)

    newIndices.push(mi0)
    newIndices.push(mi1)
    newIndices.push(mi2)

    newIndices.push(mi2)
    newIndices.push(mi1)
    newIndices.push(indices[2])

    newPointers = []
    for p in data.pointers
      newPointers.push({name: p.name, dim: p.dim, offset: p.offset})

  toString: () -> "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"