describe "Matrix", ->

  sigDigits = 7

  it "should use a default constructor to create an identity matrix", ->
    m = new Matrix()
    expect(m.elements()).toEqual [1,0,0,0,
                                  0,1,0,0,
                                  0,0,1,0,
                                  0,0,0,1]

  it "should accept an array to create a matrix", ->
    m = new Matrix([1,2,3,4, 5,6,7,8, 1,2,3,4, 5,6,7,8])
    expect(m.elements()).toEqual [1,2,3,4,
                                  5,6,7,8,
                                  1,2,3,4,
                                  5,6,7,8]

  it "should give access to an identity matrix", ->
    expect(Matrix.identity().elements()).toEqual [1,0,0,0,
                                                  0,1,0,0,
                                                  0,0,1,0,
                                                  0,0,0,1]

  it "should create a rotation matrix", ->
    degrees = 45; axisX = 1; axisY = 0; axisZ = 0
    r = Matrix.rotation(degrees,axisX,axisY,axisZ)
    actual = [1, 0, 0, 0,
              0, 0.70710678, 0.70710678, 0,
              0, -0.70710678, 0.70710678, 0,
              0, 0, 0, 1]
    expect(e).toBeCloseTo(actual[i], sigDigits) for e,i in r.elements()

  it "should create a translation matrix", ->
    x = 1; y = 2; z = 3
    t = Matrix.translation(x,y,z)
    expect(t.elements()).toEqual [1, 0, 0, 0,
                                  0, 1, 0, 0,
                                  0, 0, 1, 0,
                                  1, 2, 3, 1]

  it "should create a scaling matrix", ->
    x = 1; y = 2; z = 3
    s = Matrix.scalation(x,y,z)
    expect(s.elements()).toEqual [1, 0, 0, 0,
                                  0, 2, 0, 0,
                                  0, 0, 3, 0,
                                  0, 0, 0, 1]

  it "should rotate an existing matrix", ->
    moveX = 1; moveY = 2; moveZ = 3; degrees = 45; axisX = 1; axisY = 0; axisZ = 0
    m = Matrix.translation(moveX,moveY,moveZ).rotate(degrees,axisX,axisY,axisZ)
    actual = [1, 0, 0, 0,
              0, 0.70710678, 0.70710678, 0,
              0, -0.70710678, 0.70710678, 0,
              1, 2, 3, 1]
    expect(e).toBeCloseTo(actual[i], sigDigits) for e,i in m.elements()

  it "should translate an existing matrix", ->
    firstX = 1; firstY = 2; firstZ = 3; secondX = 4; secondY = 5; secondZ = 6
    m = Matrix.translation(firstX,firstY,firstZ).translate(secondX,secondY,secondZ)
    expect(m.elements()).toEqual [1, 0, 0, 0,
                                  0, 1, 0, 0,
                                  0, 0, 1, 0,
                                  5, 7, 9, 1]

  it "should scale an existing matrix", ->
    moveX = 1; moveY = 2; moveZ = 3; scaleX = 2; scaleY = 0.5; scaleZ = 0.25
    m = Matrix.translation(moveX,moveY,moveZ).scale(scaleX,scaleY,scaleZ)
    expect(m.elements()).toEqual [2, 0, 0, 0,
                                  0, 0.5, 0, 0,
                                  0, 0, 0.25, 0,
                                  1, 2, 3, 1]

  it "should create a look-at view matrix", ->
    eye = [0, 0, -10]; center = [0,0,0]; up = [0,1,0]
    v = Matrix.lookAt(eye,center,up)
    expect(v.elements()).toEqual [-1, 0, 0, 0,
                                  0, 1, 0, 0,
                                  0, 0, -1, 0,
                                  0, 0, -10, 1]

  it "should create an orthographic projection matrix", ->
    left = -2; right = 2; bottom = -2; top = 2; near = 1; far = 100
    projection = Matrix.ortho(left,right,bottom,top,near,far)
    actual = [0.5, 0, 0, 0,
              0, 0.5, 0, 0,
              0, 0, -0.0202020, 0,
              -0, -0, -1.0202020, 1]
    expect(e).toBeCloseTo(actual[i], sigDigits) for e,i in projection.elements()

  it "should create a perspective projection matrix", ->
    fov = 30; width = 300; height = 200; near = 1; far = 100
    projection = Matrix.perspective(fov, width  / height, near, far)
    actual = [2.48803387, 0, 0, 0,
              0, 3.7320508, 0, 0,
              0, 0, -1.0202020, -1,
              0, 0, -2.0202020, 0]
    expect(e).toBeCloseTo(actual[i], sigDigits) for e,i in projection.elements()

  it "should build a matrix from an array of arrays", ->
    flattened = Matrix.flatten [[1,2,3,4], [5,6,7,8], [9,0,1,2], [3,4,5,6]]
    expect(flattened.elements()).toEqual [1,2,3,4,
                                          5,6,7,8,
                                          9,0,1,2,
                                          3,4,5,6]

  it "should return an array of rows", ->
    rows = new Matrix([1,2,3,4, 5,6,7,8, 9,0,1,2, 3,4,5,6]).rows()
    expect(rows.length).toEqual 4
    expect(rows[0]).toEqual [1,2,3,4]
    expect(rows[1]).toEqual [5,6,7,8]
    expect(rows[2]).toEqual [9,0,1,2]
    expect(rows[3]).toEqual [3,4,5,6]

  it "should return an array of columns", ->
    cols = new Matrix([0,9,8,7, 6,5,4,3, 2,1,0,9, 8,7,6,5]).cols()
    expect(cols.length).toEqual 4
    expect(cols[0]).toEqual [0,6,2,8]
    expect(cols[1]).toEqual [9,5,1,7]
    expect(cols[2]).toEqual [8,4,0,6]
    expect(cols[3]).toEqual [7,3,9,5]


  it "should multiply two matrices", ->
    a = new Matrix([1,2,3,4, 5,6,7,8, 9,0,1,2, 3,4,5,6])
    b = new Matrix([0,9,8,7, 6,5,4,3, 2,1,0,9, 8,7,6,5])
    expect(a.multiply(b).elements()).toEqual [ 50, 50, 40, 60,
                                              114, 138, 112, 156,
                                              18, 96, 84, 82,
                                              82, 94, 76, 108 ]