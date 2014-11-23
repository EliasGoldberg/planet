class @Matrix
  constructor: (array) -> @m = if array? then array else Matrix.identity()

  @identity: -> new Matrix([1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1])

  @rotation: (angle,x,y,z) ->
    radian = Math.PI * angle / 180.0
    cosB = Math.cos(radian); sinB = Math.sin(radian)
    new Matrix([
        cosB+x*x*(1-cosB),   y*x*(1-cosB)+z*sinB, z*x*(1-cosB)-y*sinB, 0.0,
        x*y*(1-cosB)-z*sinB, cosB + y*y*(1-cosB), z*y*(1-cosB)+x*sinB, 0.0,
        x*z*(1-cosB)+y*sinB, y*z*(1-cosB)-x*sinB, cosB+z*z*(1-cosB),   0.0,
        0.0,                 0.0,                 0.0,                 1.0])

  @translation: (x,y,z) ->
    new Matrix([1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                  x,   y,   z, 1.0])

  @scalation: (x,y,z) ->
    new Matrix([  x, 0.0, 0.0, 0.0,
                0.0,   y, 0.0, 0.0,
                0.0, 0.0,   z, 0.0,
                0.0, 0.0, 0.0, 1.0])

  rotate: (angle,x,y,z) -> Matrix.rotation(angle,x,y,z).multiply(this)
  translate: (x,y,z) -> Matrix.translation(x,y,z).multiply(this)
  scale: (x,y,z) -> Matrix.scalation(x,y,z).multiply(this)

  multiply: (b) ->
    n = b.m
    mn = []
    for i in [0..3]
      for j in [0..3]
        sum = 0
        for k in [0..3]
          sum += @m[4*i+k] * n[4*k+j]
        mn[i*4+j] = sum
    new Matrix(mn)

  array: -> new Float32Array(@m)