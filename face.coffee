class @Face
  constructor: (v1,v2,v3) ->
    b1 = new Vector([1,0,0])
    b2 = new Vector([0,1,0])
    b3 = new Vector([0,0,1])
    @v = [v1,v2,v3]

  toString: () -> "#{@v[0]}\n#{@v[1]}\n#{@v[2]}"