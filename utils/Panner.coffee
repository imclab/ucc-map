define (require) ->
  { Vec2, Vec3 } = require('pex/geom')

  class Panner
    constructor: (window, camera, distance) ->
      @window = window
      @camera = camera
      @enabled = true
      @distance = distance || 2;
      @minDistance = distance/2 || 0.3;
      @maxDistance = distance*2 || 5;
      @clickPos = new Vec2(0, 0)
      @dragDiff = new Vec2(0, 0)
      @panScale = 0.01
      @upAxis = new Vec3(0, 0, 0)
      @forwardAxis = new Vec3(0, 0, 0)
      @rightAxis = new Vec3(0, 0, 0)
      @cameraClickPos = new Vec3(0, 0, 0)
      @cameraClickTarget = new Vec3(0, 0, 0)

      @addEventHanlders()

    addEventHanlders: () ->
      @window.on 'leftMouseDown', (e) =>
        return if e.handled || !@enabled
        @down(e.x, @window.height - e.y) #we flip the y coord to make rotating camera work

      @window.on 'mouseDragged', (e) =>
        return if e.handled || !@enabled
        @drag(e.x, @window.height - e.y) #we flip the y coord to make rotating camera work

      @window.on 'scrollWheel', (e) =>
        return if e.handled || !@enabled
        return if !@allowZooming
        @distance = Math.min(@maxDistance, Math.max(@distance + e.dy/100*(@maxDistance-@minDistance), @minDistance))
        @updateCamera()

    down: (x, y) ->
      @clickPos.set(x, y)
      @cameraClickPos.setVec3(@camera.getPosition())
      @cameraClickTarget.setVec3(@camera.getTarget())

    drag: (x, y) ->
      @dragDiff.set(x - @clickPos.x, @clickPos.y - y)
      @updateCamera()

    updateCamera: () ->
      @upAxis.setVec3(@camera.getUp())
      @forwardAxis.asSub(@camera.getTarget(), @camera.getPosition()).normalize()
      @rightAxis.asCross(@upAxis, @forwardAxis).normalize()

      @rightAxis.scale(@dragDiff.x * @panScale)
      @upAxis.scale(@dragDiff.y * @panScale)

      console.log(@upAxis, @rightAxis)
      @camera.getPosition().setVec3(@cameraClickPos).add(@rightAxis).add(@upAxis)
      @camera.getTarget().setVec3(@cameraClickTarget).add(@rightAxis).add(@upAxis)
      @camera.updateMatrices()
