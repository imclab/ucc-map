define (require) ->
  Layer = require('./Layer')
  { Vec3, Quat } = require('pex/geom')

  rayBoxIntersection = (ray, bbox, t0, t1) ->
    tmin = 0
    tmax = 0
    tymin = 0
    tymax = 0
    tzmin = 0
    tzmax = 0
    if ray.direction.x >= 0
      tmin = (bbox.min.x - ray.origin.x) / ray.direction.x
      tmax = (bbox.max.x - ray.origin.x) / ray.direction.x
    else
      tmin = (bbox.max.x - ray.origin.x) / ray.direction.x
      tmax = (bbox.min.x - ray.origin.x) / ray.direction.x
    if ray.direction.y >= 0
      tymin = (bbox.min.y - ray.origin.y) / ray.direction.y
      tymax = (bbox.max.y - ray.origin.y) / ray.direction.y
    else
      tymin = (bbox.max.y - ray.origin.y) / ray.direction.y
      tymax = (bbox.min.y - ray.origin.y) / ray.direction.y
    if ( (tmin > tymax) || (tymin > tmax) )
      return 0;

    if tymin > tmin
      tmin = tymin
    if tymax < tmax
      tmax = tymax
    if ray.direction.z >= 0
      tzmin = (bbox.min.z - ray.origin.z) / ray.direction.z
      tzmax = (bbox.max.z - ray.origin.z) / ray.direction.z
    else
      tzmin = (bbox.max.z - ray.origin.z) / ray.direction.z;
      tzmax = (bbox.min.z - ray.origin.z) / ray.direction.z;
    if (tmin > tzmax) || (tzmin > tmax)
      return 1
    if tzmin > tmin
      tmin = tzmin
    if tzmax < tmax
      tmax = tzmax
    if tmin > 0 && tmax > 0
      return 2
    return -2
    #return (tmin < t1) && (tmax > t0)

  class LayersController
    constructor: (@window, @scene, @camera) ->
      @up = new Vec3(0, 1, 0)
      @selectedLayer = null
      @dragCenter = new Vec3()
      @dragStart = new Vec3()
      @dragDelta = new Vec3()
      @dragScale = new Vec3()
      @dragStartRotationAngle = 0

      @window.on 'mouseMoved', (e) =>
        @testHit(e)

      @window.on 'leftMouseDown', (e) =>
        if @selectedLayer
          ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
          hits = ray.hitTestPlane(@selectedLayer.position, @up)
          @dragCenter.setVec3(@selectedLayer.position)
          @dragStart.setVec3(hits[0])
          @dragDelta.asSub(hits[0], @selectedLayer.position)
          @dragScale.setVec3(@selectedLayer.scale)
          @dragRotationInit = false
          @dragRotationStartAngle = @selectedLayer.rotationAngle

      @window.on 'mouseDragged', (e) =>
        if @selectedLayer
          ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
          hits = ray.hitTestPlane(@selectedLayer.position, @up)
          if e.shift
            originalDistance = @dragStart.distance(@dragCenter)
            currentDistance = hits[0].distance(@dragCenter)
            scaleRatio = currentDistance / originalDistance
            @selectedLayer.scale.set(@dragScale.x * scaleRatio, @dragScale.y * scaleRatio, @dragScale.z * scaleRatio)
          if e.option
            @dragDelta.asSub(hits[0], @selectedLayer.position)
            radians = Math.atan2(-@dragDelta.z, @dragDelta.x)
            angle = Math.floor(radians*180/Math.PI)
            if !@dragRotationInit
              @dragRotationInit = true
              @dragRotationBaseAngle = angle #-> rotateAngleBase
            dragRotationDiffAngle = angle - @dragRotationBaseAngle
            @selectedLayer.rotationAngle = @dragRotationStartAngle + dragRotationDiffAngle
          if !e.shift && !e.option
            @selectedLayer.position.setVec3(hits[0]).sub(@dragDelta)
          e.handled = true

      @window.on 'keyPressed', (e) ->


    testHit: (e) ->
      ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
      hitLayers = []
      hitPoints = []
      @scene.drawables.forEach (drawable, i) =>
        if drawable instanceof Layer
          if drawable.enabled == false then return
          drawable.selected = false
          hits = ray.hitTestPlane(drawable.position, @up)
          if hits.length > 0
            hit = hits[0]
            bbox = drawable.planeMesh.getBoundingBox()
            if hit.x >= bbox.min.x && hit.x <= bbox.max.x && hit.z >= bbox.min.z && hit.z <= bbox.max.z
              hitLayers.push(drawable)

      if hitLayers.length > 0
        hitLayers.sort (a, b) ->
          -(a.position.y - b.position.y)
        @selectedLayer = hitLayers[0]
        @selectedLayer.selected = true
      else
        @selectedLayer = null
