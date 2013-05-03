###
Simplest implementation of a tooltip. Used in the tests. Useful as an example
as well.
###
class Tourist.Tip.Simple extends Tourist.Tip.Base
  initialize: (options) ->
    $('body').append(@el)

  # Show the tip
  show: ->
    @el.show()

  # Hide the tip
  hide: ->
    @el.hide()

  _getTipElement: ->
    @el

  # Jam the content into our element
  _renderContent: (step, contentElement) ->
    @el.html(contentElement)