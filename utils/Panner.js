// Generated by CoffeeScript 1.6.2
define(function(require) {
  var Panner;

  return Panner = (function() {
    function Panner(window, camera) {
      this.window = window;
      this.camera = camera;
      this.enabled = true;
      this.distance = distance || 2;
      this.minDistance = distance / 2 || 0.3;
      this.maxDistance = distance * 2 || 5;
      this.addEventHanlders();
    }

    Panner.prototype.addEventHanlders = function() {
      var _this = this;

      this.window.on('leftMouseDown', function(e) {
        if (e.handled || !_this.enabled) {
          return;
        }
        return _this.down(e.x, _this.window.height - e.y);
      });
      this.window.on('mouseDragged', function(e) {
        if (e.handled || !_this.enabled) {
          return;
        }
        return _this.drag(e.x, _this.window.height - e.y);
      });
      return this.window.on('scrollWheel', function(e) {
        if (e.handled || !_this.enabled) {
          return;
        }
        if (!_this.allowZooming) {
          return;
        }
        _this.distance = Math.min(_this.maxDistance, Math.max(_this.distance + e.dy / 100 * (_this.maxDistance - _this.minDistance), _this.minDistance));
        return _this.updateCamera();
      });
    };

    Panner.prototype.down = function(x, y) {
      return this.updateCamera();
    };

    Panner.prototype.drag = function(x, y) {
      return this.updateCamera();
    };

    Panner.prototype.updateCamera = function() {};

    return Panner;

  })();
});
