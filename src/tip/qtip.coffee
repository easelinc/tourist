
###
Qtip based tip implementation
###
class Tourist.Tip.QTip extends Tourist.Tip.Base

  TIP_WIDTH = 6
  TIP_HEIGHT = 14
  ADJUST = 10

  OFFSETS =
    top: 80
    left: 80
    right: -80
    bottom: -80

  # defaults for the qtip flyout.
  QTIP_DEFAULTS:
    content:
      text: '..'
    show:
      ready: false
      delay: 0
      effect: (qtip) ->
        el = $(this)

        # this is a 'Corner' object. Will give us a top, bottom, etc
        side = qtip.options.position.my
        side = side[side.precedance] if side
        side = side or 'top'

        # figure out where to start the animation from
        offset = OFFSETS[side]

        # side must be top or left.
        side = 'top' if side == 'bottom'
        side = 'left' if side == 'right'

        value = parseInt(el.css(side))

        # set initial position
        css = {}
        css[side] = value + offset
        el.css(css)
        el.show()

        css[side] = value
        el.animate(css, 300, 'easeOutCubic')
        null

      autofocus: false
    hide:
      event: null
      delay: 0
      effect: false
    position:
      # set target
      # set viewport to viewport
      adjust:
        method: 'shift shift'
        scroll: false
    style:
      classes: 'ui-tour-tip',
      tip:
        height: TIP_WIDTH,
        width: TIP_HEIGHT
    events: {}
    zindex: 2000

  # Options support everything qtip supports.
  initialize: (options) ->
    options = $.extend(true, {}, @QTIP_DEFAULTS, options)
    @el.qtip(options)
    @qtip = @el.qtip('api')
    @qtip.render()

  destroy: ->
    @qtip.destroy() if @qtip
    super()

  # Show the tip
  show: ->
    @qtip.show()

  # Hide the tip
  hide: ->
    @qtip.hide()


  ###
  Private
  ###

  # Overridden to get the qtip element
  _getTipElement: ->
    $('#qtip-'+@qtip.id)

  # Override to set the target on the qtip
  _setTarget: (targetElement, step) ->
    super(targetElement, step)
    @qtip.set('position.target', targetElement or false)

  # Jam the content into the qtip's body. Also place the tip along side the
  # target element.
  _renderContent: (step, contentElement) ->

    my = step.my or 'left center'
    at = step.at or 'right center'

    @_adjustPlacement(my, at)

    @qtip.set('content.text', contentElement)
    @qtip.set('position.container', step.container or $('body'))
    @qtip.set('position.my', my)
    @qtip.set('position.at', at)

    # viewport should be set before target.
    @qtip.set('position.viewport', step.viewport or false)
    @qtip.set('position.target', step.target or false)

    setTimeout( =>
      @_renderTipBackground(my.split(' ')[0])
    , 10)

  # Adjust the placement of the flyout based on its positioning relative to
  # the target. Tip placement and position adjustment is unhandled by qtip. It
  # does provide settings for adjustment, so we use those.
  #
  # my - string like 'top center'. Position of the tip on the flyout.
  # at - string like 'top center'. Place where the tip points on the target.
  #
  # Return nothing
  _adjustPlacement: (my, at) ->
    # issue is that when tip is on left, it needs to be taller than wide, but
    # when on top it should be wider than tall. We're accounting for this
    # here.

    if my.indexOf('top') == 0
      @_adjust(0, ADJUST)

    else if my.indexOf('bottom') == 0
      @_adjust(0, -ADJUST)

    else if my.indexOf('right') == 0
      @_adjust(-ADJUST, 0)

    else
      @_adjust(ADJUST, 0)

  # Set the qtip style properties for tip size and offset.
  _adjust: (adjustX, adjusty) ->
    @qtip.set('position.adjust.x', adjustX)
    @qtip.set('position.adjust.y', adjusty)

  # Add an icon for the tip. Their canvas tips suck. This way we can have a
  # shadow on the tip.
  #
  # direction - string like 'left', 'top', etc. Placement of the tip.
  #
  # Return Nothing
  _renderTipBackground: (direction) =>
    el = $('#qtip-'+@qtip.id+' .qtip-tip')
    bg = el.find('.qtip-tip-bg')
    unless bg.length
      bg = $('<div/>', {'class': 'icon icon-tip qtip-tip-bg'})
      el.append(bg)

    bg.removeClass('top left right bottom')
    bg.addClass(direction)


