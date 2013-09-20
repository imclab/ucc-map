// Generated by CoffeeScript 1.6.2
define(function(require) {
  var Color, Cube, LineBuilder, Mesh, NodeEditor, Plane, ShowColors, SolidColor, Vec3, _ref, _ref1;

  _ref = require('pex/materials'), ShowColors = _ref.ShowColors, SolidColor = _ref.SolidColor;
  Mesh = require('pex/gl').Mesh;
  _ref1 = require('pex/geom/gen'), LineBuilder = _ref1.LineBuilder, Cube = _ref1.Cube;
  Color = require('pex/color').Color;
  Vec3 = require('pex/geom').Vec3;
  Plane = require('geom/Plane');
  return NodeEditor = (function() {
    function NodeEditor(window, camera) {
      var cube;

      this.window = window;
      this.camera = camera;
      this.currentLayer = null;
      this.enabled = false;
      this.nodes = [];
      this.lineBuilder = new LineBuilder();
      this.lineBuilder.addLine(new Vec3(0, -1, 0), new Vec3(0, 1, 0), Color.Red);
      this.mesh = new Mesh(this.lineBuilder, new ShowColors(), {
        useEdges: true
      });
      cube = new Cube(0.003, 0.0005, 0.003);
      cube.computeEdges();
      this.wireCube = new Mesh(cube, new SolidColor({
        color: Color.Red
      }), {
        useEdges: true
      });
      this.addEventHanlders();
    }

    NodeEditor.prototype.addEventHanlders = function() {
      var _this = this;

      this.window.on('leftMouseDown', function(e) {
        if (e.handled || !_this.enabled) {
          return;
        }
        return _this.cancelNextClick = false;
      });
      this.window.on('leftMouseUp', function(e) {
        var forward, hit2d, hit3d, hits, ray;

        console.log('cancelNextClick', _this.cancelNextClick);
        if (e.handled || !_this.enabled || _this.cancelNextClick) {
          return;
        }
        forward = _this.camera.getTarget().dup().sub(_this.camera.getPosition()).normalize();
        _this.layerPlane = new Plane(_this.currentLayer.position, forward);
        ray = _this.camera.getWorldRay(e.x, e.y, _this.window.width, _this.window.height);
        hits = ray.hitTestPlane(_this.layerPlane.point, _this.layerPlane.N);
        hit3d = hits[0];
        hit2d = _this.layerPlane.rebase(_this.layerPlane.project(hit3d));
        return _this.nodes.push({
          layerId: _this.currentLayer.id,
          position: hit3d,
          position2d: hit2d
        });
      });
      return this.window.on('mouseDragged', function(e) {
        _this.cancelNextClick = true;
        if (e.handled || !_this.enable) {

        }
      });
    };

    NodeEditor.prototype.setCurrentLayer = function(layer) {
      return this.currentLayer = layer;
    };

    NodeEditor.prototype.draw = function(camera) {
      this.mesh.draw(camera);
      return this.wireCube.drawInstances(camera, this.nodes);
    };

    return NodeEditor;

  })();
});
