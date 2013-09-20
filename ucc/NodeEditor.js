// Generated by CoffeeScript 1.6.2
define(function(require) {
  var Color, Cube, IO, LineBuilder, Mesh, NodeEditor, Plane, ShowColors, SolidColor, Vec2, Vec3, sqrt, _ref, _ref1, _ref2;

  _ref = require('pex/materials'), ShowColors = _ref.ShowColors, SolidColor = _ref.SolidColor;
  Mesh = require('pex/gl').Mesh;
  _ref1 = require('pex/geom/gen'), LineBuilder = _ref1.LineBuilder, Cube = _ref1.Cube;
  Color = require('pex/color').Color;
  _ref2 = require('pex/geom'), Vec2 = _ref2.Vec2, Vec3 = _ref2.Vec3;
  IO = require('pex/sys').IO;
  Plane = require('geom/Plane');
  sqrt = Math.sqrt;
  return NodeEditor = (function() {
    function NodeEditor(window, camera) {
      var cube;

      this.window = window;
      this.camera = camera;
      this.currentLayer = null;
      this.enabled = false;
      this.nodes = [];
      this.connections = [];
      this.lineBuilder = new LineBuilder();
      this.lineBuilder.addLine(new Vec3(0, 0, 0), new Vec3(0, 0, 0), Color.Red);
      this.lineMesh = new Mesh(this.lineBuilder, new ShowColors(), {
        useEdges: true
      });
      this.nodeRadius = 0.003;
      cube = new Cube(this.nodeRadius, 0.0005, this.nodeRadius);
      cube.computeEdges();
      this.wireCube = new Mesh(cube, new SolidColor({
        color: Color.Red
      }), {
        useEdges: true
      });
      this.hoverNode = null;
      this.addEventHanlders();
      this.load('nodes.txt');
    }

    NodeEditor.prototype.save = function(fileName) {
      var data,
        _this = this;

      data = {
        nodes: this.nodes,
        connections: this.connections.map(function(c) {
          return [_this.nodes.indexOf(c.a), _this.nodes.indexOf(c.b)];
        })
      };
      return IO.saveTextFile(fileName, JSON.stringify(data));
    };

    NodeEditor.prototype.load = function(fileName) {
      var _this = this;

      return IO.loadTextFile(fileName, function(data) {
        data = JSON.parse(data);
        _this.nodes = data.nodes.map(function(nodeData) {
          return {
            layerId: nodeData.layerId,
            position: new Vec3(nodeData.position.x, nodeData.position.y, nodeData.position.z),
            position2d: new Vec2(nodeData.position2d.x, nodeData.position2d.y)
          };
        });
        _this.connections = data.connections.map(function(connectionData) {
          return {
            a: _this.nodes[connectionData[0]],
            b: _this.nodes[connectionData[1]]
          };
        });
        return _this.updateConnectionsMesh();
      });
    };

    NodeEditor.prototype.addEventHanlders = function() {
      var _this = this;

      this.window.on('leftMouseDown', function(e) {
        if (e.handled || !_this.enabled) {
          return;
        }
        _this.cancelNextClick = false;
        if (_this.hoverNode) {
          _this.hoverNode.selected = !_this.hoverNode.selected;
          e.handled = true;
          return _this.cancelNextClick = true;
        }
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
          position2d: hit2d,
          color: Color.Green
        });
      });
      this.window.on('mouseMoved', function(e) {
        var forward, hit3d, hits, i, node, ray, _i, _len, _ref3, _results;

        forward = _this.camera.getTarget().dup().sub(_this.camera.getPosition()).normalize();
        _this.layerPlane = new Plane(_this.currentLayer.position, forward);
        ray = _this.camera.getWorldRay(e.x, e.y, _this.window.width, _this.window.height);
        hits = ray.hitTestPlane(_this.layerPlane.point, _this.layerPlane.N);
        hit3d = hits[0];
        _this.hoverNode = null;
        _ref3 = _this.nodes;
        _results = [];
        for (i = _i = 0, _len = _ref3.length; _i < _len; i = ++_i) {
          node = _ref3[i];
          if (node.layerId !== _this.currentLayer.id) {
            continue;
          }
          if (hit3d.distance(node.position) < _this.nodeRadius) {
            _results.push(_this.hoverNode = node);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      this.window.on('mouseDragged', function(e) {
        _this.cancelNextClick = true;
        if (e.handled || !_this.enable) {

        }
      });
      return this.window.on('keyDown', function(e) {
        if (!_this.enabled) {
          return;
        }
        switch (e.str) {
          case 'S':
            return _this.save('nodes.txt');
          case 'L':
            return _this.load('nodes.txt');
          case 'j':
            return _this.joinNodes(true);
          case 'J':
            return _this.joinNodes(false);
        }
      });
    };

    NodeEditor.prototype.getConnection = function(a, b) {
      var connection;

      connection = this.connections.filter(function(conn) {
        return (conn.a === a && conn.b === b) || (conn.a === b && conn.b === a);
      });
      if (connection.length > 0) {
        return connection[0];
      } else {
        return null;
      }
    };

    NodeEditor.prototype.joinNodes = function(connect) {
      var existingConnection, selectedNodes;

      selectedNodes = this.nodes.filter(function(node) {
        return node.selected;
      });
      if (selectedNodes.length === 2) {
        existingConnection = this.getConnection(selectedNodes[0], selectedNodes[1]);
        if (connect) {
          if (!existingConnection) {
            this.connections.push({
              a: selectedNodes[0],
              b: selectedNodes[1]
            });
            selectedNodes[0].selected = false;
            return this.updateConnectionsMesh();
          }
        } else if (existingConnection) {
          this.connections.splice(this.connections.indexOf(existingConnection), 1);
          return this.updateConnectionsMesh();
        }
      }
    };

    NodeEditor.prototype.updateConnectionsMesh = function() {
      var connection, _i, _len, _ref3, _results;

      this.lineBuilder.reset();
      _ref3 = this.connections;
      _results = [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        connection = _ref3[_i];
        _results.push(this.lineBuilder.addLine(connection.a.position, connection.b.position, Color.Red));
      }
      return _results;
    };

    NodeEditor.prototype.setCurrentLayer = function(layer) {
      return this.currentLayer = layer;
    };

    NodeEditor.prototype.draw = function(camera) {
      this.lineMesh.draw(camera);
      this.wireCube.material.uniforms.color = Color.Red;
      this.wireCube.drawInstances(camera, this.nodes.filter(function(node) {
        return !node.selected;
      }));
      this.wireCube.material.uniforms.color = Color.Blue;
      this.wireCube.drawInstances(camera, this.nodes.filter(function(node) {
        return node.selected;
      }));
      if (this.hoverNode) {
        return this.wireCube.drawInstances(camera, [this.hoverNode]);
      }
    };

    return NodeEditor;

  })();
});
