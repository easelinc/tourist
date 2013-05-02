
###
The flyout showing the content of each step.

Base class containing most of the logic. Can extend for different tooltip
implementations.
###
class Tourist.Tip.Base
  _module: 'Tourist'
  _.extend @prototype, Backbone.Events

  skipButtonTemplate: '<button class="btn btn-small pull-right tour-next">Skip this step →</button>'
  nextButtonTemplate: '<button class="btn btn-primary btn-small pull-right tour-next">Next step →</button>'

  closeButtonTemplate: '<a class="btn btn-close tour-close" href="#"><i class="icon icon-remove"></i></a>'
  okButtonTemplate: '<button class="btn btn-small tour-close btn-primary">Okay</button>'

  actionLabelTemplate: '<h4 class="action-label">{{label}}</h4>'
  actionLabels: ['Do this:', 'Then this:', 'Next this:']

  highlightClass: 'tour-highlight'

  template: _.template '''
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

  # options -
  #   model - a Tourist.Model object
  constructor: (@options={}) ->
    @el = $('<div/>')

    @initialize(options)

    @_bindClickEvents()

    Tourist.Tip.Base._cacheTip(this)

  destroy: ->
    @el.remove()

  # Render the current step as specified by the Tour Model
  #
  # step - step object
  #
  # Return this
  render: (step) ->
    @hide()

    if step
      @_setTarget(step.target or false, step)
      @_renderContent(step, @_buildContentElement(step))
      @show()

    this

  # Show the tip
  show: ->
    # override this

  # Hide the tip
  hide: ->
    # override this

  # Unhighlight and unset the current target
  cleanupCurrentTarget: ->
    @target.removeClass(@highlightClass) if @target and @target.removeClass
    @target = null

  ###
  Event Handlers
  ###

  # User clicked close or ok button
  onClickClose: (event) =>
    @trigger('click:close', this, event)
    false

  # User clicked next or skip button
  onClickNext: (event) =>
    @trigger('click:next', this, event)
    false


  ###
  Private
  ###

  _getTipElement: ->
    # Override me!

  # Jam the content into the qtip's body
  _renderContent: (step, contentElement) ->
    # Override me

  # Bind to the buttons
  _bindClickEvents: ->
    el = @_getTipElement()
    el.delegate('.tour-close', 'click', @onClickClose)
    el.delegate('.tour-next', 'click', @onClickNext)

  # Set the current target
  #
  # target - a jquery element that this flyout should point to.
  # step - step object
  #
  # Return nothing
  _setTarget: (target, step) ->
    @cleanupCurrentTarget()
    target.addClass(@highlightClass) if target and step and step.highlightTarget
    @target = target

  _buildContentElement: (step) ->
    buttons = @_buildButtons(step)

    content = $($.parseHTML(@template(
      content: step.content
      buttons: buttons
      close_button: @_buildCloseButton(step)
      counter: if step.final then '' else "step #{step.index+1} of #{step.total}"
      counter_class: if step.final then 'final' else ''
    )))
    content.find('.tour-buttons').remove() unless buttons

    @_renderActionLabels(content)

    content

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

  @_cacheTip: (tip) ->
    Tourist.Tip.Base._cachedTips = [] unless Tourist.Tip.Base._cachedTips
    Tourist.Tip.Base._cachedTips.push(tip)

  # destroy all dialogs!
  @destroy: ->
    return unless Tourist.Tip.Base._cachedTips
    for tip in Tourist.Tip.Base._cachedTips
      tip.destroy()
    Tourist.Tip.Base._cachedTips = null
