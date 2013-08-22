define (require) ->
  { Mesh, Texture2D } = require('pex/gl')
  { Vec3, Quat, BoundingBox } = require('pex/geom')
  { Plane } = require('pex/geom/gen')
  { Textured, SolidColor } = require('pex/materials')
  { Color } = require('pex/color')

  class Layer
    constructor: (imageFile) ->
      @position = new Vec3(0, 0, 0)
      @scale = new Vec3(1, 1, 1)
      @rotaiton = new Quat();

      Texture2D.load(imageFile, (texture) =>
        planeGeom = new Plane(1, texture.height/texture.width, 1, 1, 'x', 'z')
        @planeMesh = new Mesh(planeGeom, new Textured({texture:texture}))
        planeGeom.computeEdges()
        @border = new Mesh(planeGeom, new SolidColor({color:Color.Red}), { useEdges:true })
      )

    draw: (camera) ->
      if @planeMesh

        @planeMesh.position.setVec3(@position)
        @planeMesh.rotation.setQuat(@rotaiton)
        @planeMesh.scale.setVec3(@scale)

        @border.position.setVec3(@position)
        @border.rotation.setQuat(@rotaiton)
        @border.scale.setVec3(@scale)

        @planeMesh.draw(camera)
        @border.draw(camera)

