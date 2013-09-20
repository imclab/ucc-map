define (require) ->
  { ShowColors, SolidColor } = require('pex/materials')
  { Mesh } = require('pex/gl')
  { LineBuilder, Cube } = require('pex/geom/gen')
  { Color } = require('pex/color')
  { Vec3 } = require('pex/geom')
  Plane = require('geom/Plane')

  class NodeEditor
    constructor: (@window, @camera) ->
      @currentLayer = null
      @enabled = false
      @nodes = []

      @lineBuilder = new LineBuilder()
      @lineBuilder.addLine(new Vec3(0, -1, 0), new Vec3(0, 1, 0), Color.Red)
      @mesh = new Mesh(@lineBuilder, new ShowColors(), { useEdges: true})

      cube = new Cube(0.003, 0.0005, 0.003)
      cube.computeEdges()
      @wireCube = new Mesh(cube, new SolidColor({color:Color.Red}), { useEdges: true })

      @addEventHanlders()

    addEventHanlders: () ->
      @window.on 'leftMouseDown', (e) =>
        return if e.handled || !@enabled
        @cancelNextClick = false

      @window.on 'leftMouseUp', (e) =>
        console.log('cancelNextClick', @cancelNextClick)
        return if e.handled || !@enabled || @cancelNextClick
        forward = @camera.getTarget().dup().sub(@camera.getPosition()).normalize()
        @layerPlane = new Plane(@currentLayer.position, forward)
        ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
        hits = ray.hitTestPlane(@layerPlane.point, @layerPlane.N)
        hit3d = hits[0]
        hit2d = @layerPlane.rebase(@layerPlane.project(hit3d))
        @nodes.push({
          position: hit3d,
          position2d: hit2d
        })

      @window.on 'mouseDragged', (e) =>
        @cancelNextClick = true
        return if e.handled || !@enable

    setCurrentLayer: (layer) ->
      @currentLayer = layer

    draw: (camera) ->
      @mesh.draw(camera)
      @wireCube.drawInstances(camera, @nodes)
      #for node in @nodes
      #  @wireCube.position = node.position
      #  @wireCube.draw(camera, @nodes)
