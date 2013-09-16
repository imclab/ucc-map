// Generated by CoffeeScript 1.6.2
var Arcball, Color, Cube, GUI, MathUtils, Mesh, OrthographicCamera, PerspectiveCamera, Scene, Test, Vec3, pex, _ref;

pex = pex || require('./lib/pex');

_ref = pex.scene, Scene = _ref.Scene, PerspectiveCamera = _ref.PerspectiveCamera, OrthographicCamera = _ref.OrthographicCamera, Arcball = _ref.Arcball;

Mesh = pex.gl.Mesh;

Vec3 = pex.geom.Vec3;

Cube = pex.geom.gen.Cube;

Test = pex.materials.Test;

Color = pex.color.Color;

MathUtils = pex.utils.MathUtils;

GUI = pex.gui.GUI;

pex.require(['utils/GLX', 'ucc/Layer', 'ucc/LayersController'], function(GLX, Layer, LayersController) {
  return pex.sys.Window.create({
    settings: {
      width: 1280,
      height: 720,
      fullscreen: pex.sys.Platform.isBrowser
    },
    layerDistance: 0.1,
    xray: false,
    init: function() {
      var _this = this;

      this.camera = new PerspectiveCamera(60, this.width / this.height, 0.01, 100, new Vec3(0, 1, 0), new Vec3(0, 0, 0), new Vec3(0, 0, -1));
      this.scene = new Scene();
      this.gui = new GUI(this);
      this.gui.addLabel('x - xray mode');
      this.gui.addLabel('1 - ground floor');
      this.gui.addLabel('2 - 1st floor');
      this.gui.addLabel('3 - 2nd floor');
      this.gui.addLabel('a - all floors');
      MathUtils.seed(0);
      this.layers = [
        {
          img: 'assets/satellite.jpg',
          level: -1,
          enabled: false
        }, {
          img: 'assets/A0-plan.png',
          level: 0,
          enabled: true
        }, {
          img: 'assets/A1-plan.png',
          level: 1,
          enabled: true
        }, {
          img: 'assets/B0-plan.png',
          level: 0,
          enabled: true
        }, {
          img: 'assets/B1-plan.png',
          level: 1,
          enabled: true
        }, {
          img: 'assets/C0-plan.png',
          level: 0,
          enabled: true
        }, {
          img: 'assets/C1-plan.png',
          level: 1,
          enabled: true
        }, {
          img: 'assets/C2-plan.png',
          level: 2,
          enabled: true
        }
      ];
      this.layers = this.layers.map(function(layerData) {
        var layer;

        layer = new Layer(layerData.img);
        layer.position = new Vec3(Math.random() * 0.5 - 0.25, -0.02 + layerData.level * _this.layerDistance, Math.random() * 0.5 - 0.25);
        layer.rotationAngle = 0;
        layer.name = layerData.img;
        layer.level = layerData.level;
        layer.enabled = layerData.enabled;
        _this.scene.add(layer);
        return layer;
      });
      this.layersController = new LayersController(this, this.scene, this.camera);
      this.layersController.enabled = true;
      this.arcball = new Arcball(this, this.camera);
      this.glx = new GLX(this.gl);
      return this.on('keyDown', function(e) {
        var drawable, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1, _results2, _results3, _results4;

        switch (e.str) {
          case 'x':
            _this.xray = !_this.xray;
            _ref1 = _this.scene.drawables;
            _results = [];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              drawable = _ref1[_i];
              _results.push(drawable.planeMesh.material.uniforms.xray = _this.xray);
            }
            return _results;
            break;
          case '1':
            _ref2 = _this.scene.drawables;
            _results1 = [];
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              drawable = _ref2[_j];
              _results1.push(drawable.enabled = drawable.level === 0);
            }
            return _results1;
            break;
          case '2':
            _ref3 = _this.scene.drawables;
            _results2 = [];
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              drawable = _ref3[_k];
              _results2.push(drawable.enabled = drawable.level === 1);
            }
            return _results2;
            break;
          case '3':
            _ref4 = _this.scene.drawables;
            _results3 = [];
            for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
              drawable = _ref4[_l];
              _results3.push(drawable.enabled = drawable.level === 2);
            }
            return _results3;
            break;
          case 'a':
            _ref5 = _this.scene.drawables;
            _results4 = [];
            for (_m = 0, _len4 = _ref5.length; _m < _len4; _m++) {
              drawable = _ref5[_m];
              _results4.push(drawable.enabled = true);
            }
            return _results4;
        }
      });
    },
    draw: function() {
      this.glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black);
      this.layers[0].enabled = !this.xray;
      if (this.xray) {
        this.layers[0].border.draw(this.camera);
      }
      this.gl.enable(this.gl.BLEND);
      this.gl.blendFunc(this.gl.SRC_ALPHA, this.gl.ONE_MINUS_SRC_ALPHA);
      this.scene.draw(this.camera);
      return this.gui.draw();
    }
  });
});
