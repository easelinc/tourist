
###
Qtip based tip implementation
###
class Tourist.Tip.Bootstrap extends Tourist.Tip.Base

  # Options support everything qtip supports.
  initialize: (options) ->
    @tip = new Tourist.Tip.BootstrapTip()

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
    @tip.setPosition(step.target or false, my, at)


###
Simple implementation of tooltip with bootstrap markup.
###
class Tourist.Tip.BootstrapTip

  template: '''
    <div class="popover">
      <div class="arrow"></div>
      <div class="popover-content"></div>
    </div>
  '''

  constructor: (options) ->
    defs =
      offset: 10
      tipOffset: 10
    @options = _.extend(defs, options)
    @el = $($.parseHTML(@template))

  destroy: ->
    @el.remove()

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
    @el.find('.popover-content')

  _getTipElement: ->
    @el.find('.arrow')

  _setPosition: (target, my, at) ->
    [clas, shift] = my.split(' ')

    @el
      .css({ top: 0, left: 0, display: 'block' })
      .removeClass('top, left, right, bottom')
      .addClass(@FLIP_POSITION[clas])

    return unless target

    # unset the tip position
    tip = @_getTipElement().css
      left: ''
      right: ''
      top: ''
      bottom: ''

    tipOffset =
      left: tip[0].offsetWidth/2
      right: 0
      top: tip[0].offsetHeight/2
      top: 0

    if shift != 'center'
      css = {}
      css[shift] = tipOffset[shift] + @options.tipOffset
      css[@FLIP_POSITION[shift]] = 'auto'
      tip.css(css)

    targetPosition = @_caculateTargetPosition(at, target)
    tipPosition = @_caculateTipPosition(my, targetPosition)
    position = @_adjustForArrow(my, tipPosition)

    @el.offset(position)

  _caculateTargetPosition: (atPosition, target) ->
    bounds = @_getTargetBounds(target)
    pos = @_lookupPosition(atPosition, bounds.width, bounds.height)

    return {
      left: bounds.left + pos[0]
      top: bounds.top + pos[1]
    }

  _caculateTipPosition: (myPosition, targetPosition) ->
    width = @el[0].offsetWidth
    height = @el[0].offsetHeight
    pos = @_lookupPosition(myPosition, width, height)

    return {
      left: targetPosition.left - pos[0]
      top: targetPosition.top - pos[1]
    }

  _adjustForArrow: (myPosition, tipPosition) ->
    [clas, shift] = myPosition.split(' ') # will be top, left, right, or bottom

    tip = @_getTipElement()
    width = tip[0].offsetWidth
    height = tip[0].offsetHeight

    position =
      top: tipPosition.top
      left: tipPosition.left

    # adjust the main direction
    switch clas
      when 'bottom'
        position.top -= height+@options.offset
      when 'right'
        position.left -= width+@options.offset

    # shift the tip if necessary
    switch shift
      when 'left'
        position.left -= width/2+@options.tipOffset
      when 'right'
        position.left += width/2+@options.tipOffset
      when 'top'
        position.top -= height/2+@options.tipOffset
      when 'right'
        position.top += height/2+@options.tipOffset

    position

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

  FLIP_POSITION:
    bottom: 'top'
    top: 'bottom'
    left: 'right'
    right: 'left'

  _getTargetBounds: (target) ->
      el = target[0]

      if typeof el.getBoundingClientRect == 'function'
        size = el.getBoundingClientRect()
      else
        size =
          width: el.offsetWidth
          height: el.offsetHeight

      $.extend({}, size, target.offset())

