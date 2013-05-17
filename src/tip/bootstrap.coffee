
###
Qtip based tip implementation
###
class Tourist.Tip.Bootstrap extends Tourist.Tip.Base

  template: '''
    <div class="popover fade top in">
      <div class="arrow"></div>
      <div class="popover-content"></div>
    </div>
  '''

  # Options support everything qtip supports.
  initialize: (options) ->
    @tip = new BootstrapTip()

  destroy: ->
    @tip.destroy()
    super()

  # Show the tip
  show: ->
    @tip.show()

  # Hide the tip
  hide: ->
    @tip.hide()


  ###
  Private
  ###

  # Overridden to get the qtip element
  _getTipElement: ->
    @tip.el

  # Override to set the target on the qtip
  _setTarget: (targetElement, step) ->
    super(targetElement, step)
    #@tip.setTarget(targetElement)

  # Jam the content into the qtip's body. Also place the tip along side the
  # target element.
  _renderContent: (step, contentElement) ->
    my = step.my or 'left center'
    at = step.at or 'right center'

    @tip.setContainer(step.container or $('body'))
    @tip.setContent(contentElement)
    @tip.setPosition(step.targetElement or false, my, at)


###
Simple implementation of tooltip with bootstrap markup.
###
class BootstrapTip

  template: '''
    <div class="popover">
      <div class="arrow"></div>
      <div class="popover-content"></div>
    </div>
  '''

  constructor: (options) ->
    @el = $($.parseHTML(@template))

  destroy: ->
    @el.remove()
    super()

  # Show the tip
  show: ->
    @el.show().addClass('visible')

  # Hide the tip
  hide: ->
    @el.hide().removeClass('visible')

  setPosition: (@target, @my, @at) ->
    @_setPosition(@target, @my, @at)

  setContainer: (container) ->
    container.append(@el)

  setContent: (content) ->
    @_getContentElement().html(content)

  _getContentElement: ->
    @el.find('popover-content')

  _getTipElement: ->
    @el.find('arrow')

  _setPosition: (target, my, at) ->
    @el
      .css({ top: 0, left: 0, display: 'block' })

    targetPosition = @_caculateTargetPosition(at)
    tipPosition = @_caculateTargetPosition(my, targetPosition)
    position = @_adjustForArrow(my, tipPosition)

    @el.offset(position)

  _caculateTargetPosition: (atPosition) ->
    bounds = @_getTargetBounds(target)
    pos = @_lookupPosition(atPosition, bounds.width, bounds.height)

    return {
      left: bounds.left + pos[0]
      top: bounds.top + pos[1]
    }

  _caculateTipPosition: (myPosition, targetPosition) ->
    width = @el[0].offsetWidth
    height = @el[0].offsetHeight
    pos = @_lookupPosition(atPosition, width, height)

    return {
      left: pos.left + targetPosition.left
      top: pos.top + targetPosition.top
    }

  _adjustForArrow: (myPosition, tipPosition) ->
    [clas, shift] = myPosition.split(' ') # will be top, left, right, or bottom
    @el
      .removeClass('top, left, right, bottom')
      .addClass(clas)

    tip = @_getTipElement()
    width = tip[0].offsetWidth
    height = tip[0].offsetHeight

    tipPosition

  _lookupPosition: (position, width, height) ->
    width2 = width/2
    height2 = height/2

    posLookup =
      'top left': [0,0]
      'left top': [0,0]
      'top right': [width,0]
      'right top': [width,0]
      'bottom left': [0,height]
      'left bottom': [0,height]
      'bottom right': [width,height]
      'right bottom': [width,height]

      'top center': [width2,0]
      'left center': [0,height2]
      'right center': [width,height2]
      'bottom center': [width2,height]

    posLookup[position]


  _getTargetBounds: (target) ->
      el = @el[0]

      if typeof el.getBoundingClientRect == 'function'
        size = el.getBoundingClientRect()
      else
        size =
          width: el.offsetWidth
          height: el.offsetHeight

      $.extend({}, size, @el.offset())





  _setTipPosition: (offset, placement) ->
    @el
      .offset(offset)
      .addClass(placement)

    actualWidth = @el[0].offsetWidth
    actualHeight = @el[0].offsetHeight

    if placement == 'top' && actualHeight != height
      offset.top = offset.top + height - actualHeight
      replace = true

    if placement == 'bottom' || placement == 'top'
      delta = 0

      if offset.left < 0
        delta = offset.left * -2
        offset.left = 0
        $tip.offset(offset)
        actualWidth = @el[0].offsetWidth
        actualHeight = @el[0].offsetHeight

      this.replaceArrow(delta - width + actualWidth, actualWidth, 'left')

    else
      this.replaceArrow(actualHeight - height, actualHeight, 'top')

    @el.offset(offset) if replace