// Generated by CoffeeScript 1.6.2
define(function(require) {
  var BoundingBox, Color, Layer, Mesh, Plane, Platform, Quat, SolidColor, Texture2D, Textured, TexturedAlpha, Vec3, _ref, _ref1, _ref2;

  _ref = require('pex/gl'), Mesh = _ref.Mesh, Texture2D = _ref.Texture2D;
  _ref1 = require('pex/geom'), Vec3 = _ref1.Vec3, Quat = _ref1.Quat, BoundingBox = _ref1.BoundingBox;
  Plane = require('pex/geom/gen').Plane;
  _ref2 = require('pex/materials'), Textured = _ref2.Textured, SolidColor = _ref2.SolidColor;
  TexturedAlpha = require('ucc/TexturedAlpha');
  Color = require('pex/color').Color;
  Platform = require('pex/sys').Platform;
  return Layer = (function() {
    function Layer(imageFile, id) {
      var _this = this;

      this.id = id;
      this.position = new Vec3(0, 0, 0);
      this.scale = new Vec3(1, 1, 1);
      this.up = new Vec3(0, 1, 0);
      this.rotation = new Quat();
      this.axis = new Vec3(0, 1, 0);
      this.rotationAngle = 0;
      this.showImage = true;
      this.selected = false;
      this.alpha = 1;
      Texture2D.load(imageFile, function(texture) {
        var borderGeom, gl, planeGeom;

        texture.bind();
        gl = texture.gl;
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        if (Platform.isPlask) {
          gl.texParameterf(gl.TEXTURE_2D, 0x84FE, 4);
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        }
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.generateMipmap(gl.TEXTURE_2D);
        planeGeom = new Plane(1, texture.height / texture.width, 1, 1, 'x', 'z');
        _this.planeMesh = new Mesh(planeGeom, new TexturedAlpha({
          texture: texture,
          alpha: 0.5
        }));
        _this.planeMesh.updateBoundingBox();
        borderGeom = new Plane(1, texture.height / texture.width, 3, 3, 'x', 'z');
        borderGeom.computeEdges();
        return _this.border = new Mesh(borderGeom, new SolidColor({
          color: new Color(0.1, 0.99, 0.9, 1)
        }), {
          useEdges: true
        });
      });
    }

    Layer.prototype.draw = function(camera) {
      if (this.planeMesh) {
        this.rotation.setAxisAngle(this.up, this.rotationAngle);
        this.planeMesh.material.uniforms.alpha = this.alpha;
        if (!this.position.equals(this.planeMesh.position) || !this.scale.equals(this.planeMesh.scale) || !this.rotation.equals(this.planeMesh.rotation)) {
          this.planeMesh.position.setVec3(this.position);
          this.planeMesh.rotation.setQuat(this.rotation);
          this.planeMesh.scale.setVec3(this.scale);
          this.border.position.setVec3(this.position);
          this.border.rotation.setQuat(this.rotation);
          this.border.scale.setVec3(this.scale);
          this.planeMesh.updateBoundingBox();
        }
        if (this.showImage) {
          this.planeMesh.draw(camera);
        }
        if (this.selected) {
          return this.border.draw(camera);
        }
      }
    };

    return Layer;

  })();
});
