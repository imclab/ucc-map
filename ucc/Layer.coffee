define (require) ->
  { Mesh, Texture2D } = require('pex/gl')
  { Vec3, Quat, BoundingBox } = require('pex/geom')
  { Plane } = require('pex/geom/gen')
  { Textured, SolidColor } = require('pex/materials')
  TexturedAlpha = require('ucc/TexturedAlpha')
  { Color } = require('pex/color')
  { Platform } = require('pex/sys')

  class Layer
    selected: false
    alpha: 1
    constructor: (imageFile, @id) ->
      @position = new Vec3(0, 0, 0)
      @scale = new Vec3(1, 1, 1)
      @up = new Vec3(0, 1, 0)
      @rotation = new Quat()
      @axis = new Vec3(0, 1, 0)
      @rotationAngle = 0

      Texture2D.load(imageFile, (texture) =>
        texture.bind()
        gl = texture.gl
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)#_MIPMAP_NEAREST)
        #ext = gl.getExtension("MOZ_EXT_texture_filter_anisotropic");
        if Platform.isPlask
          gl.texParameterf(gl.TEXTURE_2D, 0x84FE, 4)
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.generateMipmap(gl.TEXTURE_2D)
        planeGeom = new Plane(1, texture.height/texture.width, 1, 1, 'x', 'z')
        @planeMesh = new Mesh(planeGeom, new TexturedAlpha({texture:texture, alpha:0.5}))
        @planeMesh.updateBoundingBox()
        borderGeom = new Plane(1, texture.height/texture.width, 3, 3, 'x', 'z')
        borderGeom.computeEdges()
        @border = new Mesh(borderGeom, new SolidColor({color:Color.Yellow}), { useEdges:true })
      )

    draw: (camera) ->
      if @planeMesh
        @rotation.setAxisAngle(@up, @rotationAngle)
        @planeMesh.material.uniforms.alpha = @alpha
        if !@position.equals(@planeMesh.position) || !@scale.equals(@planeMesh.scale) || !@rotation.equals(@planeMesh.rotation)
          @planeMesh.position.setVec3(@position)
          @planeMesh.rotation.setQuat(@rotation)
          @planeMesh.scale.setVec3(@scale)

          @border.position.setVec3(@position)
          @border.rotation.setQuat(@rotation)
          @border.scale.setVec3(@scale)
          @planeMesh.updateBoundingBox()

        @planeMesh.draw(camera)
        @border.draw(camera) if @selected

