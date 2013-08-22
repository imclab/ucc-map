pex = pex || require('./lib/pex')

{ Scene, PerspectiveCamera, Arcball } = pex.scene
{ Mesh } = pex.gl
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
      @camera = new PerspectiveCamera(60, @width/@height)
      @arcball = new Arcball(this, @camera)
      @scene = new Scene()
      @scene.add(new Mesh(new Cube(), new Test()))
      @glx = new GLX(@gl)

    draw: () ->
      @glx.enableDepthWriteAndRead(true, true).clearColorAndDepth(Color.Black)
      @scene.draw(@camera)