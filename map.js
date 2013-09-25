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

pex.require(['utils/GLX', 'ucc/Layer', 'ucc/LayersController', 'utils/Panner', 'geom/Plane', 'ucc/NodeEditor'], function(GLX, Layer, LayersController, Panner, Plane, NodeEditor) {
  return pex.sys.Window.create({
    settings: {
      width: 1280,
      height: 720,
      fullscreen: pex.sys.Platform.isBrowser
    },
    layerDistance: 0.1,
    xray: false,
    focusLayerId: 0,
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
          enabled: false,
          name: 'ALL',
          value: 0
        }, {
          img: 'assets/A0-plan.png',
          level: 0,
          enabled: true,
          name: 'A 0',
          value: 1
        }, {
          img: 'assets/A1-plan.png',
          level: 1,
          enabled: true,
          name: 'A 1',
          value: 2
        }, {
          img: 'assets/B0-plan.png',
          level: 0,
          enabled: true,
          name: 'B 0',
          value: 3
        }, {
          img: 'assets/B1-plan.png',
          level: 1,
          enabled: true,
          name: 'B 1',
          value: 4
        }, {
          img: 'assets/C0-plan.png',
          level: 0,
          enabled: true,
          name: 'C 0',
          value: 5
        }, {
          img: 'assets/C1-plan.png',
          level: 1,
          enabled: true,
          name: 'C 1',
          value: 6
        }, {
          img: 'assets/C2-plan.png',
          level: 2,
          enabled: true,
          name: 'C 2',
          value: 7
        }
      ];
      this.gui.addRadioList('Focus on', this, 'focusLayerId', this.layers, function(e) {
        return _this.onFocusLayerChange(e);
      });
      this.layers = this.layers.map(function(layerData, id) {
        var layer, layerYPos;

        layer = new Layer(layerData.img, id);
        layerYPos = layerData.level >= 0 ? layerData.level * _this.layerDistance : 10;
        layer.position = new Vec3(Math.random() * 0.5 - 0.25, -0.02 + layerYPos, Math.random() * 0.5 - 0.25);
        layer.rotationAngle = 0;
        layer.name = layerData.img;
        layer.level = layerData.level;
        layer.enabled = layerData.enabled;
        _this.scene.add(layer);
        return layer;
      });
      this.layersController = new LayersController(this, this.scene, this.camera);
      this.layersController.enabled = true;
      this.nodeEditor = new NodeEditor(this, this.camera);
      this.nodeEditor.enabled = false;
      this.arcball = new Arcball(this, this.camera);
      this.arcball.enabled = true;
      this.panner = new Panner(this, this.camera);
      this.panner.enabled = false;
      this.glx = new GLX(this.gl);
      this.on('keyDown', function(e) {
        var drawable, layer, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1, _results2, _results3, _results4;

        switch (e.str) {
          case 'x':
            _this.xray = !_this.xray;
            _ref1 = _this.layers;
            _results = [];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              layer = _ref1[_i];
              _results.push(layer.planeMesh.material.uniforms.xray = _this.xray);
            }
            return _results;
            break;
          case '0':
            _ref2 = _this.scene.drawables;
            _results1 = [];
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              drawable = _ref2[_j];
              drawable.enabled = drawable.level === 0;
              _results1.push(_this.onFocusLayerChange(0));
            }
            return _results1;
            break;
          case '1':
            _ref3 = _this.scene.drawables;
            _results2 = [];
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              drawable = _ref3[_k];
              drawable.enabled = drawable.level === 1;
              _results2.push(_this.onFocusLayerChange(1));
            }
            return _results2;
            break;
          case '2':
            _ref4 = _this.scene.drawables;
            _results3 = [];
            for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
              drawable = _ref4[_l];
              drawable.enabled = drawable.level === 2;
              _results3.push(_this.onFocusLayerChange(2));
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
      return this.onFocusLayerChange(0);
    },
    onFocusLayerChange: function(layerIndex) {
      var drawable, i, reorientCamera, selectedLayer, _i, _len, _ref1;

      _ref1 = this.scene.drawables;
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        drawable = _ref1[i];
        drawable.enabled = (i === layerIndex) || (0 === layerIndex);
      }
      selectedLayer = this.scene.drawables[layerIndex];
      reorientCamera = this.arcball.enabled;
      this.arcball.enabled = layerIndex === 0;
      this.layersController.enabled = layerIndex === 0;
      this.panner.enabled = layerIndex !== 0;
      this.nodeEditor.enabled = layerIndex !== 0;
      this.nodeEditor.setCurrentLayer(this.layers[layerIndex]);
      this.camera.getTarget().setVec3(selectedLayer.position);
      if (reorientCamera) {
        this.camera.setUp(new Vec3(0, 0, 1));
        this.camera.position.set(selectedLayer.position.x, selectedLayer.position.y + 1, selectedLayer.position.z);
        this.camera.updateMatrices();
        this.panner.cameraUp.setVec3(new Vec3(0, 0, 1));
      }
      if (this.panner.enabled) {
        this.panner.updateCamera();
      }
      if (this.arcball.enabled) {
        this.arcball.updateCamera();
      }
      this.focusLayerId = layerIndex;
      return this.gui.items[0].dirty = true;
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
      this.glx.enableDepthWriteAndRead(false, false);
      this.nodeEditor.draw(this.camera);
      return this.gui.draw();
    }
  });
});
