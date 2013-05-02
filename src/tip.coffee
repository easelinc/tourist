###
The flyout showing the content of each step.
###
class Tourist.Tip extends Backbone.View
  _module: 'Tourist'

  skipButtonTemplate: '<button class="btn btn-small pull-right tour-next">Skip this step →</button>'
  nextButtonTemplate: '<button class="btn btn-primary btn-small pull-right tour-next">Next step →</button>'

  closeButtonTemplate: '<a class="btn btn-close tour-close" href="#"><i class="icon icon-remove"></i></a>'
  okButtonTemplate: '<button class="btn btn-small tour-close btn-primary">Okay</button>'

  actionLabelTemplate: '<h4 class="action-label">{{label}}</h4>'
  actionLabels: ['Do this:', 'Then this:', 'Next this:']

  highlightClass: 'tour-highlight'

  template: '''
    <div>
      <div class="tour-container">
        {{close_button}}
        {{content}}
        <p class="tour-counter {{counter_class}}">{{counter}}</p>
      </div>
      <div class="tour-buttons">
        {{buttons}}
      </div>
    </div>
  '''

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

  # options -
  #   model - a Draw.TourModel object
  initialize: (@options={}) ->
    @el = $(@el)

    @el.qtip(@QTIP_DEFAULTS)
    @qtip = @el.qtip('api')
    @qtip.render()

    @_bindModel()
    @_bindClickEvents()

    Draw.TourTip._cacheTip(this)

  destroy: ->
    @qtip.destroy() if @qtip
    @el.remove()

  # Render the current step as specified by the Tour Model
  #
  # Return this
  render: ->
    @qtip.hide()

    step = @model.get('current_step')
    if step
      buttons = @_buildButtons(step)
      content = $($.parseHTML(@renderTemplate(@template,
        content: step.content
        buttons: buttons
        close_button: @_buildCloseButton(step)
        counter: if step.final then '' else "step #{step.index+1} of #{step.total}"
        counter_class: if step.final then 'final' else ''
      )))
      content.find('.tour-buttons').remove() unless buttons

      my = step.my or 'left center'
      at = step.at or 'right center'

      @_adjustPlacement(my, at)
      @_renderActionLabels(content)

      @qtip.set('content.text', content)
      @qtip.set('position.container', step.container or $('body'))
      @qtip.set('position.my', my)
      @qtip.set('position.at', at)

      # viewport should be set before target.
      @qtip.set('position.viewport', step.viewport or false)
      @setTarget(step.target or false)

      @show()

      setTimeout( =>
        @_renderTipBackground(my.split(' ')[0])
      , 10)

    this

  # Show the tip
  show: ->
    @qtip.show()

  # Hide the tip
  hide: ->
    @qtip.hide()

  # Unhighlight and unset the current target
  cleanupCurrentTarget: ->
    @target.removeClass(@highlightClass) if @target and @target.removeClass
    @target = null

  # Set the current target
  #
  # target - a jquery element that this flyout should point to.
  #
  # Return nothing
  setTarget: (target) ->
    @cleanupCurrentTarget()

    @qtip.set('position.target', target)

    step = @model.get('current_step')
    target.addClass(@highlightClass) if target and step and step.highlightTarget

    @target = target

  ###
  Event Handlers
  ###

  # Tour moved to next step
  onChangeCurrentStep: (model, step) =>
    @render()

  # User clicked close or ok button
  onClickClose: (event) =>
    pds this, 'close clicked', event
    @trigger('click:close', this, event)
    false

  # User clicked next or skip button
  onClickNext: (event) =>
    pds this, 'next clicked', event
    @trigger('click:next', this, event)
    false


  ###
  Private
  ###

  # Bind to the TourModel
  _bindModel: ->
    @model.bind('change:current_step', @onChangeCurrentStep)

  # Bind to the buttons
  _bindClickEvents: ->
    el = $('#qtip-'+@qtip.id)
    el.delegate('.tour-close', 'click', @onClickClose)
    el.delegate('.tour-next', 'click', @onClickNext)

  # Create buttons based on step options.
  #
  # Returns a string of button html to be placed into the template.
  _buildButtons: (step) ->
    buttons = ''

    buttons += @okButtonTemplate if step.okButton
    buttons += @skipButtonTemplate if step.skipButton
    buttons += @nextButtonTemplate if step.nextButton

    buttons

  _buildCloseButton: (step) ->
    if step.closeButton then @closeButtonTemplate else ''

  _renderActionLabels: (el) ->
    actions = el.find('.action')
    actionIndex = 0
    for action in actions
      label = $($.parseHTML(_.template(@actionLabelTemplate, label: @actionLabels[actionIndex])))
      label.insertBefore(action)
      actionIndex++

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

  @_cacheTip: (tip) ->
    Draw.TourTip._cachedTips = [] unless Draw.TourTip._cachedTips
    Draw.TourTip._cachedTips.push(tip)

  # destroy all dialogs!
  @destroy: ->
    return unless Draw.TourTip._cachedTips
    for tip in Draw.TourTip._cachedTips
      tip.destroy()
    Draw.TourTip._cachedTips = null
