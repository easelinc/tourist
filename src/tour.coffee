###

A way to make a tour. Basically, you specify a series of steps which explain
elements to point at and what to say. This class manages moving between those
steps.

The 'step object' is a simple js obj that specifies how the step will behave.

A simple Example of a step object:
  {
    content: '<p>Welcome to my step</p>'
    target: $('#something-to-point-at')
    closeButton: true
    highlightTarget: true
    setup: (tour, options) ->
      # do stuff in the interface/bind
    teardown: (tour, options) ->
      # remove stuff/unbind
  }

Basic Step object options:

  content - a string of html to put into the step.
  target - jquery object or absolute point: [10, 30]
  highlightTarget - optional bool, true will outline the target with a bright color.
  container - optional jquery element that should contain the step flyout.
              default: $('body')
  viewport - optional jquery element that the step flyout should stay within.
             $(window) is commonly used. default: false

  my - string position of the pointer on the tip. default: 'left center'
  at - string position on the element the tip points to. default: 'right center'
  see http://craigsworks.com/projects/qtip2/docs/position/#basics

Step object button options:

  okButton - optional bool, true will show a red ok button
  closeButton - optional bool, true will show a grey close button
  skipButton - optional bool, true will show a grey skip button
  nextButton - optional bool, true will show a red next button

Step object function options:

  All functions on the step will have the signature '(tour, options) ->'

    tour - the Draw.Tour object. Handy to call tour.next()
    options - the step options. An object passed into the tour when created.
              It has the environment that the fns can use to manipulate the
              interface, bind to events, etc. The same object is passed to all
              of a step object's functions, so it is handy for passing data
              between steps.

  setup - called before step is shown. Use to scroll to your target, hide/show things, ...

    'this' is the step object itself.

    MUST return an object. Properties in the returned object will override
    properties in the step object.

    i.e. the target might be dynamic so you would specify:

    setup: (tour, options) ->
      return { target: $('#point-to-me') }

  teardown - function called right before hiding the step. Use to unbind from
    things you bound to in setup().

    'this' is the step object itself.

    Return nothing.

  bind - an array of function names to bind. Use this for event handlers you use in setup().

    Will bind functions to the step object as this, and the first 2 args as tour and options.

    i.e.

    bind: ['onChangeSomething']
    setup: (tour, options) ->
      options.document.bind('change:something', @onChangeSomething)
    onChangeSomething: (tour, options, model, value) ->
      tour.next()
    teardown: (tour, options) ->
      options.document.unbind('change:something', @onChangeSomething)

###
class Tourist.Tour
  _.extend(@prototype, Backbone.Events)

  # options - tour options
  #   stepOptions - an object of options to be passed to each function called on a step object
  #   tipClass - the class from the Tourist.Tip namespace to use
  #   tipOptions - an object passed to the tip
  #   steps - array of step objects
  #   cancelStep - step object for a step that runs if hit the close button.
  #   successStep - step object for a step that runs last when they make it all the way through.
  constructor: (@options={}) ->
    defs =
      tipClass: 'Bootstrap'
    @options = _.extend(defs, @options)

    @model = new Tourist.Model
      current_step: null

    # there is only one tooltip. It will rerender for each step
    tipOptions = _.extend({model: @model}, @options.tipOptions)
    @view = new Tourist.Tip[@options.tipClass](tipOptions)

    @view.bind('click:close', _.bind(@stop, this, true))
    @view.bind('click:next', @next)

    @model.bind('change:current_step', @onChangeCurrentStep)


  ###
  Public
  ###

  # Starts the tour
  #
  # Return nothing
  start: ->
    @trigger('start', this)
    @next()

  # Resets the data and runs the final step
  #
  # doFinalStep - bool whether or not you want to run the final step
  #
  # Return nothing
  stop: (doFinalStep) ->
    if doFinalStep
      @_showCancelFinalStep()
    else
      @_stop()

  # Move to the next step
  #
  # Return nothing
  next: =>
    currentStep = @model.get('current_step')
    index = if currentStep then currentStep.index+1 else 0

    if index < @options.steps.length
      @_teardownStep(currentStep)
      @_showStep(@options.steps[index], index)
    else if index == @options.steps.length
      @_showSuccessFinalStep()
    else
      @_stop()

  # Set the stepOptions which is basically like the state for the tour.
  setStepOptions: (stepOptions) ->
    @options.stepOptions = stepOptions


  ###
  Handlers
  ###

  # Called when the current step changes on the model.
  onChangeCurrentStep: (model, step) =>
    @view.render(step)

  ###
  Private
  ###

  # Show the cancel final step - they closed it at some point.
  #
  # Return nothing
  _showCancelFinalStep: ->
    @_showFinalStep(false)

  # Show the success final step - they made it all the way through.
  #
  # Return nothing
  _showSuccessFinalStep: ->
    @_showFinalStep(true)

  # Stop the tour and reset the state.
  #
  # Return nothing
  _stop: ->
    @_teardownStep(@model.get('current_step'))
    @model.set(current_step: null)
    @trigger('stop', this)

  # Shows a final step.
  #
  # success - bool whether or not to show the success final step. False shows
  #   the cancel final step.
  #
  # Return nothing
  _showFinalStep: (success) ->

    currentStep = @model.get('current_step')

    finalStep = if success then @options.successStep else @options.cancelStep

    if _.isFunction(finalStep)
      finalStep.call(this, this, @options.stepOptions)
      finalStep = null

    return @_stop() unless finalStep
    return @_stop() if currentStep and currentStep.final

    finalStep.final = true
    @_teardownStep(currentStep)
    @_showStep(finalStep, @options.steps.length)

  # Sets step to the current_step in our model. Does all the neccessary setup.
  #
  # step - a step object
  # index - int indexof the step 0 based.
  #
  # Return nothing
  _showStep: (step, index) ->
    return unless step

    step = _.clone(step)
    step.index = index
    step.total = @options.steps.length

    unless step.final
      step.final = (@options.steps.length == index+1 and not @options.successStep)

    # can pass dynamic options from setup
    step = _.extend(step, @_setupStep(step))

    @model.set(current_step: step)

  # Setup an arbitrary step
  #
  # step - a step object from @options.steps
  #
  # Returns the return value from step.setup. This will be an object with
  # properties that will override those in the current step object
  _setupStep: (step) ->
    return {} unless step and step.setup

    # bind to any handlers on the step object
    if step.bind
      for fn in step.bind
        step[fn] = _.bind(step[fn], step, this, @options.stepOptions)

    step.setup.call(step, this, @options.stepOptions) or {}

  # Teardown an arbitrary step
  #
  # step - a step object from @options.steps
  #
  # Return nothing
  _teardownStep: (step) ->
    step.teardown.call(step, this, @options.stepOptions) if step and step.teardown
    @view.cleanupCurrentTarget()
