describe "Tourist.Tour", ->
  beforeEach ->
    loadFixtures('tests/base.html')

    @options =
      this: 1
      that: 34

    @steps = [{
      content: '''
        <p class="one">One</p>
      '''
      target: $('#test')
      highlightTarget: true
      closeButton: true
      nextButton: true
      setup: (tour, options) ->
      teardown: ->
    },{
      content: '''
        <p class="two">Step Two</p>
      '''
      closeButton: true
      skipButton: true
      setup: ->
        {target: $('#menu')}
      teardown: ->
    },{
      content: '''
        <p class="three action">Step Three</p>
      '''
      closeButton: true
      nextButton: true
      setup: ->
      teardown: ->
    }]

    @finalQuit =
      content: '''
        <p class="finalquit">The user quit early</p>
      '''
      okButton: true
      setup: ->
      teardown: ->

    @finalSucceed =
      content: '''
        <p class="finalsuccess">User made it all the way through</p>
      '''
      okButton: true
      setup: ->
      teardown: ->

    @s = new Draw.Tour
      stepOptions: @options
      steps: @steps
      cancelStep: @finalQuit
      successStep: @finalSucceed

  afterEach: ->
    @s.view.qtip.destroy()

  describe 'basics', ->
    it 'inits', ->
      expect(@s.model instanceof Draw.TourModel).toEqual(true)
      expect(@s.view instanceof Draw.TourTip).toEqual(true)

  describe 'rendering', ->
    it 'starts and updates the view', ->
      @s.start()
      @s.next()
      @s.next()

      el = $('#qtip-'+@s.view.qtip.id)
      expect(el.find('.action')).toExist()
      expect(el.find('.action-label')).toExist()
      expect(el.find('.action-label').text()).toEqual('Do this:')

  describe 'stepping', ->
    it 'starts and updates the model', ->
      expect(@s.model.get('current_step')).toEqual(null)

      @s.start()

      expect(@s.model.get('current_step')).not.toEqual(null)
      expect(@s.model.get('current_step').index).toEqual(0)

    it 'starts and updates the view', ->
      @s.start()
      el = $('#qtip-'+@s.view.qtip.id)
      expect(el).toShow()
      expect(el.find('.one')).toExist()
      expect(el.find('.two')).not.toExist()

      expect(el.find('.tour-counter').text()).toEqual('step 1 of 3')

    it 'calls setup', ->
      spyOn(@steps[0], 'setup')

      @s.start()

      expect(@steps[0].setup).toHaveBeenCalledWith(@s, @options)

    it 'calls teardown', ->
      spyOn(@steps[0], 'teardown')
      spyOn(@steps[1], 'setup')

      @s.start()
      @s.next()

      expect(@steps[0].teardown).toHaveBeenCalledWith(@s, @options)
      expect(@steps[1].setup).toHaveBeenCalledWith(@s, @options)

    it 'moves to the next step', ->
      @s.start()
      @s.next()

      expect(@s.model.get('current_step').index).toEqual(1)

      el = $('#qtip-'+@s.view.qtip.id)
      expect(el).toShow()
      expect(el.find('.one')).not.toExist()
      expect(el.find('.two')).toExist()

    it 'calls the final step when through all steps', ->
      @s.start()
      @s.next()
      @s.next()
      @s.next()

      expect(@s.model.get('current_step').index).toEqual(3)
      expect(@s.model.get('current_step').final).toEqual(true)

      el = $('#qtip-'+@s.view.qtip.id)
      expect(el).toShow()
      expect(el.find('.three')).not.toExist()
      expect(el.find('.finalsuccess')).toExist()

    it 'calls the function when successStep is just a function', ->
      callback = jasmine.createSpy()
      @s.options.successStep = callback

      @s.start()
      @s.next()
      @s.next()
      @s.next()

      expect(callback).toHaveBeenCalled()

    it 'stops after the final step', ->
      @s.start()
      @s.next()
      @s.next()
      @s.next()
      @s.next()

      expect(@s.model.get('current_step')).toEqual(null)

      el = $('#qtip-'+@s.view.qtip.id)
      #expect(el).toHide()

    it 'targets an element returned from setup', ->
      @s.start()
      @s.next()

      expect(@s.view.target[0]).toEqual($('#menu')[0])

    it 'highlights and unhighlights when neccessary', ->
      @s.start()

      expect($('#test')).toHaveClass('tour-highlight')

      @s.next()

      expect($('#menu')).not.toHaveClass('tour-highlight')
      expect($('#test')).not.toHaveClass('tour-highlight')

  describe 'stop()', ->
    it 'pops final cancel step when I pass it true', ->
      @s.start()
      @s.next()
      @s.stop(true)

      expect(@s.model.get('current_step').final).toEqual(true)

      el = $('#qtip-'+@s.view.qtip.id)
      expect(el.find('.finalquit')).toExist()

    it 'actually stops when I pass falsy value', ->
      @s.start()
      @s.next()
      @s.stop()

      expect(@s.model.get('current_step')).toEqual(null)

    it 'unhighlights current thing', ->
      @s.start()
      @s.stop()
      expect(@s.model.get('current_step')).toEqual(null)
      expect($('#test')).not.toHaveClass('tour-highlight')

    it 'called when final step open will really stop', ->
      @s.start()
      @s.next()
      @s.stop(true)
      @s.stop(true)

      expect(@s.model.get('current_step')).toEqual(null)

    it 'handles case when no final step', ->
      @s.options.cancelStep = null

      @s.start()
      @s.next()
      @s.stop(true)

      expect(@s.model.get('current_step')).toEqual(null)

    it 'calls teardown on step before final', ->
      spyOn(@steps[1], 'teardown')
      spyOn(@finalQuit, 'setup')

      @s.start()
      @s.next()
      @s.stop(true)

      expect(@steps[1].teardown).toHaveBeenCalledWith(@s, @options)
      expect(@finalQuit.setup).toHaveBeenCalledWith(@s, @options)

    it 'calls teardown on final', ->
      spyOn(@finalQuit, 'teardown')

      @s.start()
      @s.next()
      @s.stop(true)
      @s.stop(true)

      expect(@finalQuit.teardown).toHaveBeenCalledWith(@s, @options)

  describe 'interaction with view buttons', ->

    it 'handles next button', ->
      @s.start()
      @s.view.onClickNext({})
      expect(@s.model.get('current_step').index).toEqual(1)

    it 'handles close button', ->
      @s.start()
      @s.view.onClickClose({})
      expect(@s.model.get('current_step').final).toEqual(true)

      @s.view.onClickClose({})
      expect(@s.model.get('current_step')).toEqual(null)


