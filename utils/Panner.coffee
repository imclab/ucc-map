define (require) ->
  class Panner
    constructor: (window, camera) ->
      @window = window
      @camera = camera
      @enabled = true
      @distance = distance || 2;
      @minDistance = distance/2 || 0.3;
      @maxDistance = distance*2 || 5;

      @addEventHanlders()

    addEventHanlders: () ->
      @window.on 'leftMouseDown', (e) =>
        return if e.handled || !@enabled
        @down(e.x, @window.height - e.y) #we flip the y coord to make rotating camera work

      @window.on 'mouseDragged', (e) =>
        return if e.handled || !@enabled
        @drag(e.x, @window.height - e.y) #we flip the y coord to make rotating camera work

      @window.on 'scrollWheel', (e) =>
        return if e.handled || !@enabled
        return if !@allowZooming
        @distance = Math.min(@maxDistance, Math.max(@distance + e.dy/100*(@maxDistance-@minDistance), @minDistance))
        @updateCamera()

    down: (x, y) ->
      @updateCamera()

    drag: (x, y) ->
      @updateCamera()

    updateCamera: () ->
