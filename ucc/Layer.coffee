define (require) ->
  { Mesh, Texture2D } = require('pex/gl')
  { Vec3, Quat, BoundingBox } = require('pex/geom')
  { Plane } = require('pex/geom/gen')
  { Textured, SolidColor } = require('pex/materials')
  { Color } = require('pex/color')

  class Layer
    selected: false
    constructor: (imageFile) ->
      @position = new Vec3(0, 0, 0)
      @scale = new Vec3(1, 1, 1)
      @rotaiton = new Quat();

      Texture2D.load(imageFile, (texture) =>
        planeGeom = new Plane(1, texture.height/texture.width, 1, 1, 'x', 'z')
        @planeMesh = new Mesh(planeGeom, new Textured({texture:texture}))
        @planeMesh.updateBoundingBox()
        borderGeom = new Plane(1, texture.height/texture.width, 3, 3, 'x', 'z')
        borderGeom.computeEdges()
        @border = new Mesh(borderGeom, new SolidColor({color:Color.Red}), { useEdges:true })
      )

    draw: (camera) ->
      if @planeMesh

        if !@position.equals(@planeMesh.position) || !@scale.equals(@planeMesh.scale)# || !@rotation.equals(@planeMesh.rotation)
          @planeMesh.position.setVec3(@position)
          @planeMesh.rotation.setQuat(@rotaiton)
          @planeMesh.scale.setVec3(@scale)

          @border.position.setVec3(@position)
          @border.rotation.setQuat(@rotaiton)
          @border.scale.setVec3(@scale)
          @planeMesh.updateBoundingBox()

        @planeMesh.draw(camera)
        @border.draw(camera) if @selected

