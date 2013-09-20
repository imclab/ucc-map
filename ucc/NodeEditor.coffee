define (require) ->
  class NodeEditor
    constructor: (@window, @camera) ->
      @currentLayer = null
      @enabled = false

    addEventHanlders: () ->
      @window.on 'leftMouseDown', (e) =>
        return if e.handled || !@enabled

      @window.on 'mouseDragged', (e) =>
        return if e.handled || !@enable