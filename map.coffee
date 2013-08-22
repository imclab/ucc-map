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
    init: () ->
      @camera = new PerspectiveCamera(60, @width/@height, 0.1, 100, new Vec3(0, 2, 0), new Vec3(0, 0, 0), new Vec3(0, 0, -1))
      #@arcball = new Arcball(this, @camera)
      @scene = new Scene()
      @scene.add(new Layer('assets/satellite.jpg'))
      @glx = new GLX(@gl)

    draw: () ->
      @glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black)
      @scene.draw(@camera)