pex = pex || require('./lib/pex')

{ Scene, PerspectiveCamera, OrthographicCamera, Arcball } = pex.scene
{ Mesh } = pex.gl
{ Vec3 } = pex.geom
{ Cube } = pex.geom.gen
{ Test } = pex.materials
{ Color } = pex.color
{ MathUtils } = pex.utils
{ GUI } = pex.gui

pex.require ['utils/GLX','ucc/Layer', 'ucc/LayersController'], (GLX, Layer, LayersController) ->
  pex.sys.Window.create
    settings:
      width: 1280
      height: 720
      fullscreen: pex.sys.Platform.isBrowser
    layerDistance: 0.1
    xray: false
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
        { img: 'assets/satellite.jpg', level: -1, enabled: false}
        { img: 'assets/A0-plan.png',   level:  0, enabled: true}
        { img: 'assets/A1-plan.png',   level:  1, enabled: true}
        { img: 'assets/B0-plan.png',   level:  0, enabled: true}
        { img: 'assets/B1-plan.png',   level:  1, enabled: true}
        { img: 'assets/C0-plan.png',   level:  0, enabled: true}
        { img: 'assets/C1-plan.png',   level:  1, enabled: true}
        { img: 'assets/C2-plan.png',   level:  2, enabled: true}
      ]

      @layers = @layers.map (layerData) =>
        layer = new Layer(layerData.img)
        layer.position = new Vec3(Math.random()*0.5-0.25, -0.02 + layerData.level * @layerDistance, Math.random()*0.5-0.25)
        layer.rotationAngle = 0;
        layer.name = layerData.img
        layer.level = layerData.level
        layer.enabled = layerData.enabled
        @scene.add(layer)
        layer

      @layersController = new LayersController(this, @scene, @camera)
      @layersController.enabled = true

      @arcball = new Arcball(this, @camera)
      @glx = new GLX(@gl)

      @on 'keyDown', (e) =>
        switch e.str
          when 'x'
            @xray = !@xray
            for drawable in @scene.drawables
              drawable.planeMesh.material.uniforms.xray = @xray
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

    draw: () ->
      @glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black)
      @layers[0].enabled = !@xray
      @layers[0].border.draw(@camera) if @xray

      @gl.enable(@gl.BLEND)
      @gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA)
      @scene.draw(@camera)

      @gui.draw()