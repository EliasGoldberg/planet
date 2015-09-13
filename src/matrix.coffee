class @Matrix
  constructor: (array) -> @m = if array? then array else Matrix.identity().m
  array: -> new Float32Array(@m)
  elements: -> @m

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

  @lookAt: (eye,center,up) ->
    eyeV = new Vector(eye)
    centerV = new Vector(center)
    upV = new Vector(up)
    f = centerV.minus(eyeV).normalize()
    s = f.crossProduct(upV).normalize()
    u = s.crossProduct(f)

    new Matrix([s.a[0], u.a[0], -f.a[0], 0,
                s.a[1], u.a[1], -f.a[1], 0,
                s.a[2], u.a[2], -f.a[2], 0,
                0, 0, 0, 1]).translate(-eye[0],-eye[1], -eye[2])

  @ortho: (l, r, b, t, n, f) ->
    rw = 1 / (r - l)
    rh = 1 / (t - b)
    rd = 1 / (f - n)
    new Matrix([         2*rw,            0,              0, 0,
                            0,         2*rh,              0, 0,
                            0,             0,         -2*rd, 0,
                -(r + l) * rw, -(t + b) * rh, -(f + n) * rd, 1])

  @perspective: (fovy, aspect, near, far) ->
    fovy = Math.PI * fovy / 180 / 2
    rd = 1 / (far - near)
    ct = Math.cos(fovy) / Math.sin(fovy)
    new Matrix([ ct / aspect,  0,                    0,  0,
                           0, ct,                    0,  0,
                           0,  0,   -(far + near) * rd, -1,
                           0,  0, -2 * near * far * rd,  0])

  @flatten: (arrays) -> new Matrix [].concat.apply([], arrays)

  rows: -> @m[i..i+3] for i in [0..@m.length-1] by 4
  cols: -> [@m[i], @m[i+4], @m[i+8], @m[i+12]] for i in [0..3]
  multiply: (b) -> Matrix.flatten(r[0]*c[0] + r[1]*c[1] + r[2]*c[2] + r[3]*c[3] for c in b.cols() for r in this.rows())
