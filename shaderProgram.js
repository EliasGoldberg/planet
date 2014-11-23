// Generated by CoffeeScript 1.6.3
(function() {
  this.ShaderProgram = (function() {
    function ShaderProgram(gl) {
      this.gl = gl;
      this.program = this.gl.createProgram();
    }

    ShaderProgram.prototype.addShader = function(type, source) {
      var message, shader;
      shader = this.gl.createShader(type);
      this.gl.shaderSource(shader, source);
      this.gl.compileShader(shader);
      message = this.gl.getShaderInfoLog(shader);
      if ((message != null) && message !== '') {
        console.log(message);
      }
      return this.gl.attachShader(this.program, shader);
    };

    ShaderProgram.prototype.activate = function() {
      var message;
      this.gl.linkProgram(this.program);
      message = this.gl.getProgramInfoLog(this.program);
      if ((message != null) && message !== '') {
        console.log(message);
      }
      return this.gl.useProgram(this.program);
    };

    ShaderProgram.prototype.setAttrib = function(name, value) {
      var attrib, vertexAttrib;
      attrib = this.gl.getAttribLocation(this.program, name);
      vertexAttrib = this.getVertexAttribMethodName(value);
      return this.gl[vertexAttrib](attrib, value);
    };

    ShaderProgram.prototype.setUniform = function(name, value) {
      var uniform;
      uniform = this.gl.getUniformLocation(this.program, name);
      return this.gl.uniform4fv(uniform, value);
    };

    ShaderProgram.prototype.setUniformMatrix = function(name, value) {
      var uniform;
      uniform = this.gl.getUniformLocation(this.program, name);
      return this.gl.uniformMatrix4fv(uniform, false, value);
    };

    ShaderProgram.prototype.setAttribPointer = function(name, values) {
      var attrib, vertexBuffer;
      attrib = this.gl.getAttribLocation(this.program, name);
      vertexBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, vertexBuffer);
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(values), this.gl.STATIC_DRAW);
      this.gl.vertexAttribPointer(attrib, 2, this.gl.FLOAT, false, 0, 0);
      this.gl.enableVertexAttribArray(attrib);
      return values.length / 2;
    };

    ShaderProgram.prototype.getVertexAttribMethodName = function(value) {
      var isVector, size, vee;
      isVector = value.length != null;
      size = isVector ? value.length : 1;
      vee = isVector ? 'v' : '';
      return "vertexAttrib" + size + "f" + vee;
    };

    return ShaderProgram;

  })();

}).call(this);

/*
//@ sourceMappingURL=shaderProgram.map
*/