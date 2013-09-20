define (require) ->
  class Plane
    Vec3 = require('pex/geom/Vec3')
    Vec2 = require('pex/geom/Vec2')
    { abs, sqrt } = Math

    constructor: (@point, normal) ->
      @N = normal
      @U = new Vec3()
      @V = new Vec3()
      if abs(@N.x) > abs(@N.y)
        invLen = 1 / sqrt(@N.x * @N.x + @N.z * @N.z)
        @U.set( @N.x * invLen, 0, -@N.z * invLen)
      else
        invLen = 1 / sqrt(@N.y * @N.y + @N.z * @N.z)
        @U.set( 0, @N.z * invLen, -@N.y * invLen)

      @V.setVec3(@N).cross(@U)

    project: (p) ->
      D = Vec3.create().asSub(p, @point)
      scale = D.dot(@N)
      scaled = @N.clone().scale(scale)
      projected = p.clone().sub(scaled)

    rebase: (p) ->
      diff = p.dup().sub(@point)
      x = @U.dot(diff)
      y = @V.dot(diff)
      return new Vec2(x, y)