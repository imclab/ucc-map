pex = pex || require('./lib/pex')

{ Scene, PerspectiveCamera, OrthographicCamera, Arcball } = pex.scene
{ Mesh } = pex.gl
{ Vec3 } = pex.geom
{ Cube } = pex.geom.gen
{ Test } = pex.materials
{ Color } = pex.color
{ MathUtils } = pex.utils
{ GUI } = pex.gui

pex.require ['utils/GLX','ucc/Layer', 'ucc/LayersController', 'utils/Panner', 'geom/Plane', 'ucc/NodeEditor'],
(GLX, Layer, LayersController, Panner, Plane, NodeEditor) ->
  pex.sys.Window.create
    settings:
      width: 1280
      height: 720
      fullscreen: pex.sys.Platform.isBrowser
    layerDistance: 0.1
    xray: false
    focusLayerId: 0,
    init: () ->
      @camera = new PerspectiveCamera(60, @width/@height, 0.01, 100, new Vec3(0, 1, 0), new Vec3(0, 0, 0), new Vec3(0, 0, -1))
      #@camera = new OrthographicCamera(-@width/@height, @width/@height, -1, 1, 0.1, 100, new Vec3(0, 1, 0), new Vec3(0, 0, 0), new Vec3(0, 0, -1))
      @scene = new Scene()

      @gui = new GUI(this)
      @gui.addLabel('x - xray mode')
      @gui.addLabel('1 - ground floor')
      @gui.addLabel('2 - 1st floor')
      @gui.addLabel('3 - 2nd floor')
      @gui.addLabel('a - all floors')

      MathUtils.seed(0)

      @layers = [
        { img: 'assets/satellite.jpg', level: -1, enabled: false, name: 'ALL', value:0 }
        { img: 'assets/A0-plan.png',   level:  0, enabled: true , name: 'A 0' , value:1 }
        { img: 'assets/A1-plan.png',   level:  1, enabled: true , name: 'A 1' , value:2 }
        # { img: 'assets/B0-plan.png',   level:  0, enabled: true , name: 'B 0' , value:3 }
        # { img: 'assets/B1-plan.png',   level:  1, enabled: true , name: 'B 1' , value:4 }
        # { img: 'assets/C0-plan.png',   level:  0, enabled: true , name: 'C 0' , value:5 }
        # { img: 'assets/C1-plan.png',   level:  1, enabled: true , name: 'C 1' , value:6 }
        # { img: 'assets/C2-plan.png',   level:  2, enabled: true , name: 'C 2' , value:7 }
      ]

      @gui.addRadioList('Focus on', this, 'focusLayerId', @layers, (e) => @onFocusLayerChange(e))

      @layers = @layers.map (layerData, id) =>
        layer = new Layer(layerData.img, id)
        layer.position = new Vec3(Math.random()*0.5-0.25, -0.02 + layerData.level * @layerDistance, Math.random()*0.5-0.25)
        layer.rotationAngle = 0;
        layer.name = layerData.img
        layer.level = layerData.level
        layer.enabled = layerData.enabled
        @scene.add(layer)
        layer

      @layersController = new LayersController(this, @scene, @camera)
      @layersController.enabled = true

      @nodeEditor = new NodeEditor(this, @camera)
      @nodeEditor.enabled = false
      @scene.add(@nodeEditor)
      @arcball = new Arcball(this, @camera)
      @arcball.enabled = true
      @panner = new Panner(this, @camera)
      @panner.enabled = false

      @glx = new GLX(@gl)

      @on 'keyDown', (e) =>
        switch e.str
          when 'x'
            @xray = !@xray
            for layer in @layers
              layer.planeMesh.material.uniforms.xray = @xray
          when '1'
            for drawable in @scene.drawables
              drawable.enabled = drawable.level == 0
          when '2'
            for drawable in @scene.drawables
              drawable.enabled = drawable.level == 1
          when '3'
            for drawable in @scene.drawables
              drawable.enabled = drawable.level == 2
          when 'a'
            for drawable in @scene.drawables
              drawable.enabled = true

      @onFocusLayerChange(1)

    onFocusLayerChange: (layerIndex) ->
      for drawable, i in @scene.drawables
        drawable.enabled = (i == layerIndex) || (0 == layerIndex)
      selectedLayer = @scene.drawables[layerIndex]

      @arcball.enabled = (layerIndex == 0)
      @layersController.enabled = (layerIndex == 0)
      @panner.enabled = (layerIndex != 0)
      @nodeEditor.enabled = (layerIndex != 0)
      @nodeEditor.setCurrentLayer(@layers[layerIndex])
      @camera.getTarget().setVec3(selectedLayer.position)
      @camera.setUp(new Vec3(0, 0, 1))
      @camera.position.set(selectedLayer.position.x, selectedLayer.position.y + 1, selectedLayer.position.z)
      @camera.updateMatrices()
      @panner.cameraUp.setVec3(new Vec3(0, 0, 1))
      @panner.updateCamera() if @panner.enabled
      @arcball.updateCamera() if @arcball.enabled

    draw: () ->
      @glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black)
      @layers[0].enabled = !@xray
      @layers[0].border.draw(@camera) if @xray
      @gl.enable(@gl.BLEND)
      @gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA)
      @scene.draw(@camera)

      @gui.draw()