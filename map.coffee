pex = pex || require('./lib/pex')

{ Scene, PerspectiveCamera, Arcball } = pex.scene
{ Mesh } = pex.gl
{ Vec3 } = pex.geom
{ Cube } = pex.geom.gen
{ Test } = pex.materials
{ Color } = pex.color
{ MathUtils } = pex.utils

pex.require ['utils/GLX','ucc/Layer'], (GLX, Layer) ->
  pex.sys.Window.create
    settings:
      width: 1280
      height: 720
      fullscreen: pex.sys.Platform.isBrowser
    layerDistance: 0.1
    init: () ->
      @camera = new PerspectiveCamera(60, @width/@height, 0.1, 100, new Vec3(0, 1, 0), new Vec3(0, 0, 0), new Vec3(0, 0, -1))
      @arcball = new Arcball(this, @camera)
      @scene = new Scene()

      @layers = [
        { img: 'assets/satellite.jpg', level: -1 }
        { img: 'assets/A0-plan.png', level: 0 }
        { img: 'assets/A1-plan.png', level: 1 }
      ]

      @layers = @layers.map (layerData) =>
        layer = new Layer(layerData.img)
        layer.position = new Vec3(Math.random()*0.5-0.25, -0.02 + layerData.level * @layerDistance, Math.random()*0.5-0.25)
        @scene.add(layer)

      @glx = new GLX(@gl)

    draw: () ->
      @glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black)
      #@gl.enable(@gl.BLEND)
      @gl.blendFunc(@gl.ONE_MINUS_SRC_COLOR, @gl.ONE)
      @scene.draw(@camera)