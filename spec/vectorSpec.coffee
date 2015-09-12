describe "Vector", ->

  it "should normalize a vector so its magnitude is one", ->
    expect(new Vector([3,0,0]).normalize().elements()).toEqual [1,0,0]
    expect(new Vector([0,0.1,0]).normalize().elements()).toEqual [0,1,0]
    expect(new Vector([3,4,0]).normalize().elements()[0]).toBeCloseTo 0.6, 5
    expect(new Vector([3,4,0]).normalize().elements()[1]).toBeCloseTo 0.8, 5

  it "should perform the cross product of two vectors", ->
    v1 = new Vector [1,0,0]
    v2 = new Vector [0,1,0]
    expect(v1.crossProduct(v2).elements()).toEqual [0,0,1]

  it "should subtract two vectors", ->
    v1 = new Vector [4,5,6]
    v2 = new Vector [1,2,3]
    expect(v1.minus(v2).elements()).toEqual [3,3,3]

  it "should nor two vectors to produce unique barycentric coordinates", ->
    expect(Vector.nor [1,0,0], [0,1,0]).toEqual [0,0,1]
    expect(Vector.nor [1,0,0], [0,0,1]).toEqual [0,1,0]
    expect(Vector.nor [0,1,0], [1,0,0]).toEqual [0,0,1]
    expect(Vector.nor [0,1,0], [0,0,1]).toEqual [1,0,0]
    expect(Vector.nor [0,0,1], [1,0,0]).toEqual [0,1,0]
    expect(Vector.nor [0,0,1], [0,1,0]).toEqual [1,0,0]

  it "should print a pretty string", ->
    expect(new Vector([1,2,3]).toString()).toEqual "1, 2, 3"
