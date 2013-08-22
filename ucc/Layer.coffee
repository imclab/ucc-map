define (require) ->
  { Mesh, Texture2D } = require('pex/gl')
  { Plane } = require('pex/geom/gen')
  { Textured } = require('pex/materials')
  class Layer extends Mesh
    constructor: (imageFile) ->
      geom = new Plane(1, 1, 1, 1, 'x', 'z')
      material = new Textured()
      super(geom, material)
      material.uniforms.texture = Texture2D.load(imageFile, (e) =>
        console.log(e.height/e.width)
        @scale.set(1, 1, e.height/e.width)
        console.log(e.width, e.height)
      )
