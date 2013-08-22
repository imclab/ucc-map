pex = pex || require('./lib/pex')

{ Scene, PerspectiveCamera, Arcball } = pex.scene
{ Mesh } = pex.gl
{ Vec3 } = pex.geom
{ Cube } = pex.geom.gen
{ Test } = pex.materials
{ Color } = pex.color

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
      for layer in @layers
        layer.mesh = new Layer(layer.img)
        layer.mesh.position = new Vec3(0, -0.02 + layer.level * @layerDistance, 0)
        @scene.add(layer.mesh)

      @glx = new GLX(@gl)

    draw: () ->
      @glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black)
      #@gl.enable(@gl.BLEND)
      @gl.blendFunc(@gl.ONE_MINUS_SRC_COLOR, @gl.ONE)
      @scene.draw(@camera)