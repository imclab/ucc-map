define (require) ->
  Layer = require('./Layer')
  Plane = require('../geom/Plane')
  { Vec3, Quat, Mat4, Triangle2D, BoundingBox } = require('pex/geom')
  { IO } = require('pex/sys')

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
    compactLayers: false
    enabled: true
    constructor: (@window, @scene, @camera) ->
      @up = new Vec3(0, 1, 0)
      @selectedLayer = null
      @dragCenter = new Vec3()
      @dragStart = new Vec3()
      @dragDelta = new Vec3()
      @dragScale = new Vec3()
      @dragStartRotationAngle = 0

      @loadLayers('layers.txt')

      @window.on 'mouseMoved', (e) =>
        return if !@enabled
        @testHit(e)

      @window.on 'leftMouseDown', (e) =>
        return if !@enabled
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
        return if !@enabled
        if @selectedLayer
          ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
          hits = ray.hitTestPlane(@selectedLayer.position, @up)
          if !e.shift and !e.option
            @selectedLayer.position.setVec3(hits[0]).sub(@dragDelta)
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
          e.handled = true

      @window.on 'keyDown', (e) =>
        return if !@enabled
        switch e.str
          when '-' then if @selectedLayer then @selectedLayer.alpha = Math.max(0, @selectedLayer.alpha - 0.1)
          when '=' then if @selectedLayer then @selectedLayer.alpha = Math.min(1, @selectedLayer.alpha + 0.1)
          when 'S' then @saveLayers('layers.txt')
          when 'L' then @loadLayers('layers.txt')
        switch e.keyCode
          when 48 then @toggleCompactLayers()

    toggleCompactLayers: () ->
      @compactLayers = !@compactLayers
      @scene.drawables.forEach (drawable, i) =>
        if drawable instanceof Layer
          drawable.position.y = if @compactLayers then drawable.level * 0.005 else drawable.level * 0.1

    saveLayers: (fileName) ->
      console.log('LayersController.saveLayers ' + fileName)
      data = {}
      @scene.drawables.forEach (drawable, i) =>
        if drawable instanceof Layer
          layer = drawable
          data[layer.name] = {
            position: layer.position
            scale: layer.scale
            rotationAngle: layer.rotationAngle
          }
      IO.saveTextFile(fileName, JSON.stringify(data))

    loadLayers: (fileName) =>
      console.log('LayersController.loadLayers ' + fileName)
      IO.loadTextFile(fileName, (dataStr) =>
        data = JSON.parse(dataStr)
        @scene.drawables.forEach (drawable, i) =>
          if drawable instanceof Layer
            layer = drawable
            if !data[layer.name] then return
            layer.position.x = data[layer.name].position.x
            layer.position.y = data[layer.name].position.y
            layer.position.z = data[layer.name].position.z
            layer.scale.x = data[layer.name].scale.x
            layer.scale.y = data[layer.name].scale.y
            layer.scale.z = data[layer.name].scale.z
            layer.rotationAngle = data[layer.name].rotationAngle
      )

    testHit: (e) ->
      ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
      hitLayers = []
      hitPoints = []
      @scene.drawables.forEach (drawable, i) =>
        if drawable instanceof Layer and i > 0
          if drawable.enabled == false then return
          drawable.selected = false
          hits = ray.hitTestPlane(drawable.position, @up)
          bbox = BoundingBox.fromPoints( drawable.planeMesh.geometry.vertices )

          plane = new Plane(drawable.position, @up)
          if hits.length > 0
            hit = hits[0]
            hit2d = plane.rebase(plane.project(hit))
            # 1. bbox to corners

            corners = [
              new Vec3(bbox.min.x, bbox.max.y, bbox.min.z)
              new Vec3(bbox.max.x, bbox.max.y, bbox.min.z)
              new Vec3(bbox.max.x, bbox.max.y, bbox.max.z)
              new Vec3(bbox.min.x, bbox.max.y, bbox.max.z)
            ]
            corners = corners.map (v) =>
              v.dup().transformMat4(drawable.planeMesh.modelWorldMatrix)

            # 2. project corners on the plane
            # 3. convert points to 2d
            corners2d = corners.map(plane.project.bind(plane)).map(plane.rebase.bind(plane))

            # 4. build two triangles from corner points
            triangle1 = new Triangle2D(corners2d[0], corners2d[1], corners2d[2])
            triangle2 = new Triangle2D(corners2d[0], corners2d[2], corners2d[3])

            # 5. check if hit point belong to any of the tirangles
            if triangle1.contains(hit2d) || triangle2.contains(hit2d)
              hitLayers.push(drawable)

      if hitLayers.length > 0
        hitLayers.sort (a, b) ->
          -(a.position.y - b.position.y)
        @selectedLayer = hitLayers[0]
        @selectedLayer.selected = true
      else
        @selectedLayer = null
