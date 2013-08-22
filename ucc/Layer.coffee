define (require) ->
  { Mesh, Texture2D } = require('pex/gl')
  { Plane } = require('pex/geom/gen')
  { Textured } = require('pex/materials')
  class Layer extends Mesh
    constructor: (imageFile) ->
      geom = new Plane(1, 1, 1, 1, 'x', 'z')
      texture = Texture2D.load(imageFile, (e) ->
        console.log(e.width, e.height)
      )
      material = new Textured({ texture : texture })
      super(geom, material)
