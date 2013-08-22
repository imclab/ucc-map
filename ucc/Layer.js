// Generated by CoffeeScript 1.6.2
define(function(require) {
  var BoundingBox, Color, Layer, Mesh, Plane, Quat, SolidColor, Texture2D, Textured, Vec3, _ref, _ref1, _ref2;

  _ref = require('pex/gl'), Mesh = _ref.Mesh, Texture2D = _ref.Texture2D;
  _ref1 = require('pex/geom'), Vec3 = _ref1.Vec3, Quat = _ref1.Quat, BoundingBox = _ref1.BoundingBox;
  Plane = require('pex/geom/gen').Plane;
  _ref2 = require('pex/materials'), Textured = _ref2.Textured, SolidColor = _ref2.SolidColor;
  Color = require('pex/color').Color;
  return Layer = (function() {
    Layer.prototype.selected = false;

    function Layer(imageFile) {
      var _this = this;

      this.position = new Vec3(0, 0, 0);
      this.scale = new Vec3(1, 1, 1);
      this.rotaiton = new Quat();
      Texture2D.load(imageFile, function(texture) {
        var borderGeom, planeGeom;

        planeGeom = new Plane(1, texture.height / texture.width, 1, 1, 'x', 'z');
        _this.planeMesh = new Mesh(planeGeom, new Textured({
          texture: texture
        }));
        borderGeom = new Plane(1, texture.height / texture.width, 3, 3, 'x', 'z');
        borderGeom.computeEdges();
        return _this.border = new Mesh(borderGeom, new SolidColor({
          color: Color.Red
        }), {
          useEdges: true
        });
      });
    }

    Layer.prototype.draw = function(camera) {
      if (this.planeMesh) {
        if (!this.position.equals(this.planeMesh.position)) {
          this.planeMesh.updateBoundingBox();
        }
        this.planeMesh.position.setVec3(this.position);
        this.planeMesh.rotation.setQuat(this.rotaiton);
        this.planeMesh.scale.setVec3(this.scale);
        this.border.position.setVec3(this.position);
        this.border.rotation.setQuat(this.rotaiton);
        this.border.scale.setVec3(this.scale);
        this.planeMesh.draw(camera);
        if (this.selected) {
          return this.border.draw(camera);
        }
      }
    };

    return Layer;

  })();
});
