define (require) ->
  Layer = require('./Layer')
  { Vec3 } = require('pex/geom')
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

      @window.on 'mouseMoved', (e) =>
        @testHit(e)

    testHit: (e) ->
      ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
      hitLayers = []
      @scene.drawables.forEach (drawable) =>
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
