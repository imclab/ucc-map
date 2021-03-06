define (require) ->
  { ShowColors, SolidColor } = require('pex/materials')
  { Mesh } = require('pex/gl')
  { LineBuilder, Cube } = require('pex/geom/gen')
  { Color } = require('pex/color')
  { Vec2, Vec3 } = require('pex/geom')
  { IO } = require('pex/sys')
  Plane = require('geom/Plane')
  { sqrt } = Math

  class NodeEditor
    constructor: (@window, @camera) ->
      @normalColor = new Color(1.0, 0.2, 0.0, 1.0)
      @selectedColor = new Color(0.0, 0.7, 1.0, 1.0)
      @currentLayer = null
      @enabled = false
      @nodes = []
      @connections = []

      @lineBuilder = new LineBuilder()
      @lineBuilder.addLine(new Vec3(0, 0, 0), new Vec3(0, 0, 0), @normalColor)
      @lineMesh = new Mesh(@lineBuilder, new ShowColors(), { useEdges: true})

      @nodeRadius = 0.003
      cube = new Cube(@nodeRadius, 0.0005, @nodeRadius)
      cube.computeEdges()
      @wireCube = new Mesh(cube, new SolidColor({color:@normalColor}), { useEdges: true })

      @hoverNode = null

      @addEventHanlders()

      @load('nodes.txt')

    save: (fileName) ->
      data = {
       nodes: @nodes
       connections: @connections.map((c) => [@nodes.indexOf(c.a), @nodes.indexOf(c.b)])
      }
      IO.saveTextFile(fileName, JSON.stringify(data))

    load: (fileName) ->
      IO.loadTextFile(fileName, (data) =>
        data = JSON.parse(data)
        @nodes = data.nodes.map (nodeData) -> {
          layerId: nodeData.layerId,
          position: new Vec3(nodeData.position.x, nodeData.position.y, nodeData.position.z)
          position2d: new Vec2(nodeData.position2d.x, nodeData.position2d.y)
        }
        @connections = data.connections.map (connectionData) => {
          a: @nodes[connectionData[0]]
          b: @nodes[connectionData[1]]
        }
        @updateConnectionsMesh()
      )

    addEventHanlders: () ->
      @window.on 'leftMouseDown', (e) =>
        return if e.handled || !@enabled
        @cancelNextClick = false
        @draggedNode = @hoverNode

      @window.on 'leftMouseUp', (e) =>
        return if e.handled || !@enabled
        selectedNodes = @nodes.filter((node) -> node.selected)
        if @cancelNextClick
          if !e.shift
            for node in selectedNodes
              node.selected = false if node != @hoverNode
          if @draggedNode then @draggedNode.selected = true
          @draggedNode = null
          return
        if @hoverNode
          if !e.shift
            for node in selectedNodes
              node.selected = false if node != @hoverNode
          @hoverNode.selected = !@hoverNode.selected
          e.handled = true
          @cancelNextClick = true
          @draggedNode = null
        else
          forward = @camera.getTarget().dup().sub(@camera.getPosition()).normalize()
          @layerPlane = new Plane(@currentLayer.position, forward)
          ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
          hits = ray.hitTestPlane(@layerPlane.point, @layerPlane.N)
          hit3d = hits[0]
          hit2d = @layerPlane.rebase(@layerPlane.project(hit3d))
          @nodes.push({
            layerId: @currentLayer.id
            position: hit3d,
            position2d: hit2d,
            color: Color.Green
          })

      @window.on 'mouseMoved', (e) =>
        forward = @camera.getTarget().dup().sub(@camera.getPosition()).normalize()
        @layerPlane = new Plane(@currentLayer.position, forward)
        ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
        hits = ray.hitTestPlane(@layerPlane.point, @layerPlane.N)
        hit3d = hits[0]
        @hoverNode = null
        for node, i in @nodes
          if node.layerId != @currentLayer.id then continue
          if hit3d.distance(node.position) < @nodeRadius
            @hoverNode = node

      @window.on 'mouseDragged', (e) =>
        @cancelNextClick = true
        return if e.handled || !@enabled
        if @draggedNode
          forward = @camera.getTarget().dup().sub(@camera.getPosition()).normalize()
          @layerPlane = new Plane(@currentLayer.position, forward)
          ray = @camera.getWorldRay(e.x, e.y, @window.width, @window.height)
          hits = ray.hitTestPlane(@layerPlane.point, @layerPlane.N)
          hit3d = hits[0]
          @draggedNode.position = hit3d
          e.handled = true
          @updateConnectionsMesh()

      @window.on 'keyDown', (e) =>
        return if !@enabled
        switch e.str
          when 'S' then @save('nodes.txt')
          when 'L' then @load('nodes.txt')
          when 'j' then @joinNodes(true)
          when 'J' then @joinNodes(false)
        switch e.keyCode
          when 51 then @deleteNodes()

    deleteNodes: () ->
      selectedNodes = @nodes.filter((node) -> node.selected)
      for node in selectedNodes
        nodeIndex = @nodes.indexOf(node)
        nodeConnections = @connections.filter (c) -> c.a == node || c.b == node
        for connection in nodeConnections
          connectionIndex = @connections.indexOf(connection)
          @connections.splice(connectionIndex, 1)
        @nodes.splice(nodeIndex, 1)
      @hoverNode = null
      @draggedNode = null
      @updateConnectionsMesh()

    getConnection: (a, b) ->
      connection = @connections.filter (conn) ->
        return (conn.a == a && conn.b == b) || (conn.a == b && conn.b == a)

      if connection.length > 0 then connection[0]
      else null

    joinNodes: (connect) ->
      selectedNodes = @nodes.filter((node) -> node.selected)
      if selectedNodes.length == 2
        existingConnection = @getConnection(selectedNodes[0], selectedNodes[1])
        if connect
          if !existingConnection
            @connections.push({
              a: selectedNodes[0]
              b: selectedNodes[1]
            })
            selectedNodes[0].selected = false
            selectedNodes[1].selected = false
            @updateConnectionsMesh()
        else if existingConnection
          @connections.splice(@connections.indexOf(existingConnection), 1)
          @updateConnectionsMesh()

    updateConnectionsMesh: () ->
      @lineBuilder.reset()
      currentLayerConnections = @connections.filter (connection) =>
        return @currentLayer && @isNodeVisible(connection.a) && @isNodeVisible(connection.b)
      for connection in currentLayerConnections
        @lineBuilder.addLine(connection.a.position, connection.b.position, @normalColor)

    setCurrentLayer: (layer) ->
      @currentLayer = layer
      @updateConnectionsMesh()

    isNodeVisible: (node) ->
      return @currentLayer.id == 0 || node.layerId == @currentLayer.id

    draw: (camera) ->
      if @lineBuilder.vertices.length > 0
        @lineMesh.draw(camera)

      @wireCube.material.uniforms.color = @normalColor
      @wireCube.drawInstances(camera, @nodes.filter((node) => !node.selected && @isNodeVisible(node)))
      @wireCube.material.uniforms.color = @selectedColor
      @wireCube.drawInstances(camera, @nodes.filter((node) => node.selected && @isNodeVisible(node)))
      @wireCube.drawInstances(camera, [@hoverNode]) if @hoverNode
      #for node in @nodes
      #  @wireCube.position = node.position
      #  @wireCube.draw(camera, @nodes)
