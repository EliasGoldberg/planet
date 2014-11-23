// Generated by CoffeeScript 1.6.3
(function() {
  var Matrix, Program, main;

  main = function() {
    var canvas, gl, n, program;
    canvas = document.getElementById('gl');
    gl = canvas.getContext('experimental-webgl');
    program = new Program(gl);
    program.addShader(gl.VERTEX_SHADER, 'attribute vec4 a_Position;\nuniform mat4 u_xformMatrix;\nvoid main() {\n     gl_Position = u_xformMatrix * a_Position;\n}');
    program.addShader(gl.FRAGMENT_SHADER, 'void main() {\n  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n}');
    program.activate();
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);
    program.setUniformMatrix('u_xformMatrix', Matrix.rotation(90));
    n = program.setAttribPointer('a_Position', [0.0, 0.5, -0.5, -0.5, 0.5, -0.5]);
    return gl.drawArrays(gl.TRIANGLES, 0, n);
  };

  Program = (function() {
    function Program(gl) {
      this.gl = gl;
      this.program = this.gl.createProgram();
    }

    Program.prototype.addShader = function(type, source) {
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

    Program.prototype.activate = function() {
      var message;
      this.gl.linkProgram(this.program);
      message = this.gl.getProgramInfoLog(this.program);
      if ((message != null) && message !== '') {
        console.log(message);
      }
      return this.gl.useProgram(this.program);
    };

    Program.prototype.setAttrib = function(name, value) {
      var attrib, vertexAttrib;
      attrib = this.gl.getAttribLocation(this.program, name);
      vertexAttrib = this.getVertexAttribMethodName(value);
      return this.gl[vertexAttrib](attrib, value);
    };

    Program.prototype.setUniform = function(name, value) {
      var uniform;
      uniform = this.gl.getUniformLocation(this.program, name);
      return this.gl.uniform4fv(uniform, value);
    };

    Program.prototype.setUniformMatrix = function(name, value) {
      var uniform;
      uniform = this.gl.getUniformLocation(this.program, name);
      return this.gl.uniformMatrix4fv(uniform, false, value);
    };

    Program.prototype.setAttribPointer = function(name, values) {
      var attrib, vertexBuffer;
      attrib = this.gl.getAttribLocation(this.program, name);
      vertexBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, vertexBuffer);
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(values), this.gl.STATIC_DRAW);
      this.gl.vertexAttribPointer(attrib, 2, this.gl.FLOAT, false, 0, 0);
      this.gl.enableVertexAttribArray(attrib);
      return values.length / 2;
    };

    Program.prototype.getVertexAttribMethodName = function(value) {
      var isVector, size, vee;
      isVector = value.length != null;
      size = isVector ? value.length : 1;
      vee = isVector ? 'v' : '';
      return "vertexAttrib" + size + "f" + vee;
    };

    return Program;

  })();

  Matrix = (function() {
    function Matrix() {}

    Matrix.rotation = function(angle) {
      var cosB, radian, sinB;
      radian = Math.PI * angle / 180.0;
      cosB = Math.cos(radian);
      sinB = Math.sin(radian);
      return new Float32Array([cosB, sinB, 0.0, 0.0, sinB, cosB, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]);
    };

    return Matrix;

  })();

  $(main);

}).call(this);

/*
//@ sourceMappingURL=main.map
*/
