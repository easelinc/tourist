###
Simplest implementation of a tooltip
###
class Tourist.Tip.Simple extends Tourist.Tip.Base
  initialize: (options) ->

  # Show the tip
  show: ->
    @el.show()

  # Hide the tip
  hide: ->
    @el.hide()

  _getTipElement: ->
    @el

  # Jam the content into the qtip's body
  _renderContent: (step, contentElement) ->
    @el.html(contentElement)