define (require) ->
  { Vec2, Vec3 } = require('pex/geom')
  { Time } = require('pex/utils')

  class Panner
    constructor: (window, camera, distance) ->
      @window = window
      @camera = camera
      @enabled = true
      @allowZooming = true
      @distance = distance || 2;
      @minDistance = distance*0.1 || 0.1;
      @maxDistance = distance*2 || 5;
      @clickPos = new Vec2(0, 0)
      @dragDiff = new Vec2(0, 0)
      @panScale = 0.01
      @upAxis = new Vec3(0, 0, 0)
      @forwardAxis = new Vec3(0, 0, 0)
      @rightAxis = new Vec3(0, 0, 0)
      @cameraClickPos = new Vec3(0, 0, 0)
      @cameraClickTarget = new Vec3(0, 0, 0)
      @dragCenter = new Vec3()
      @dragStart = new Vec3()
      @dragDelta = new Vec3()
      @dragScale = new Vec3()
      @dragStartRotationAngle = 0

      @addEventHanlders()

    addEventHanlders: () ->
      @window.on 'leftMouseDown', (e) =>
        return if e.handled || !@enabled
        @down(e.x, @window.height - e.y, e) #we flip the y coord to make rotating camera work

      @window.on 'mouseDragged', (e) =>
        return if e.handled || !@enabled
        @drag(e.x, @window.height - e.y, e) #we flip the y coord to make rotating camera work

      @window.on 'scrollWheel', (e) =>
        return if e.handled || !@enabled
        return if !@allowZooming
        @distance = Math.min(@maxDistance, Math.max(@distance + e.dy/100*(@maxDistance-@minDistance), @minDistance))
        @updateCamera()

    down: (x, y, e) ->
      @dragCenter.setVec3(@camera.getTarget())
      ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
      @up = Vec3.create().asSub(@camera.getPosition(), @camera.getTarget()).normalize()
      hits = ray.hitTestPlane(@dragCenter, @up)
      @dragStart.setVec3(hits[0])
      @dragDelta.asSub(hits[0], @dragCenter)


    drag: (x, y, e) ->
      ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
      hits = ray.hitTestPlane(@dragCenter, @up)
      if !e.shift and !e.option
        diff = Vec3.create().asSub(@dragStart, hits[0])
        @camera.getTarget().setVec3(@dragCenter).add(diff)
        @updateCamera()
        #update drag center because @camera world ray influences hit test
        @dragCenter.setVec3(@camera.getTarget())

    updateCamera: () ->
      if !@up
        @up = Vec3.create().asSub(@camera.getPosition(), @camera.getTarget()).normalize()
      @camera.getPosition().setVec3(@up).scale(@distance).add(@camera.getTarget())
      @camera.updateMatrices()
