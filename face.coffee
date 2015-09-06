class @Face
  constructor: (v1,v2,v3) -> @v = [v1,v2,v3]

  toString: () -> "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"