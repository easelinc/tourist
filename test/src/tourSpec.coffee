window.BasicTourTests = (description, tourGenerator) ->
  describe "Tourist.Tour #{description}", ->
    beforeEach ->
      loadFixtures('tour.html')

      @options =
        this: 1
        that: 34

      @steps = [{
        content: '''
          <p class="one">One</p>
        '''
        target: $('#target-one')
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
          {target: $('#target-two')}
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
        target: $('#target-one')
        setup: ->
        teardown: ->

      @finalSucceed =
        content: '''
          <p class="finalsuccess">User made it all the way through</p>
        '''
        okButton: true
        target: $('#target-one')
        setup: ->
        teardown: ->

      @s = tourGenerator.call(this)

    afterEach ->
      Tourist.Tip.Base.destroy()

    describe 'basics', ->
      it 'inits', ->
        expect(@s.model instanceof Tourist.Model).toEqual(true)
        expect(@s.view instanceof Tourist.Tip[@s.options.tipClass]).toEqual(true)

    describe 'rendering', ->
      it 'starts and updates the view', ->
        @s.start()
        @s.next()
        @s.next()

        el = @s.view._getTipElement()
        expect(el.find('.action')).toExist()
        expect(el.find('.action-label')).toExist()
        expect(el.find('.action-label').text()).toEqual('Do this:')

    describe 'zIndex parameter', ->
      it 'uses specified z-index', ->
        @steps[0].zIndex = 4000
        @s.start()
        el = @s.view._getTipElement()
        expect(el.attr('style')).toContain('z-index: 4000')

      it 'clears z-index when not specified', ->
        @steps[0].zIndex = 4000
        @s.start()
        @s.next()
        el = @s.view._getTipElement()
        expect(el.attr('style')).not.toContain('z-index: 4000')

    describe 'stepping', ->
      it 'starts and updates the model', ->
        expect(@s.model.get('current_step')).toEqual(null)

        @s.start()

        expect(@s.model.get('current_step')).not.toEqual(null)
        expect(@s.model.get('current_step').index).toEqual(0)

      it 'starts and updates the view', ->
        @s.start()
        el = @s.view._getTipElement()
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

        el = @s.view._getTipElement()
        expect(el).toShow()
        expect(el.find('.one')).not.toExist()
        expect(el.find('.two')).toExist()

      it 'calls the final step when through all steps', ->
        @s.start()
        @s.next()
        @s.next()
        expect(@s.model.get('current_step').final).toEqual(false)

        @s.next()
        expect(@s.model.get('current_step').index).toEqual(3)
        expect(@s.model.get('current_step').final).toEqual(true)

        el = @s.view._getTipElement()
        expect(el).toShow()
        expect(el.find('.three')).not.toExist()
        expect(el.find('.finalsuccess')).toExist()

      it 'last step is final when no successStep', ->
        @s.options.successStep = null

        @s.start()
        @s.next()
        @s.next()

        expect(@s.model.get('current_step').index).toEqual(2)
        expect(@s.model.get('current_step').final).toEqual(true)

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

        el = @s.view._getTipElement()
        #expect(el).toHide() # no worky in qtip tests. Works in real life.

      it 'targets an element returned from setup', ->
        @s.start()
        @s.next()

        expect(@s.view.target[0]).toEqual($('#target-two')[0])

      it 'highlights and unhighlights when neccessary', ->
        @s.start()

        expect($('#target-one')).toHaveClass('tour-highlight')

        @s.next()

        expect($('#target-two')).not.toHaveClass('tour-highlight')
        expect($('#target-one')).not.toHaveClass('tour-highlight')

    describe 'stop()', ->
      it 'pops final cancel step when I pass it true', ->
        @s.start()
        @s.next()
        @s.stop(true)

        expect(@s.model.get('current_step').final).toEqual(true)

        el = @s.view._getTipElement()
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
        expect($('#target-one')).not.toHaveClass('tour-highlight')

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

      it 'calls teardown of last step only once', ->
        spyOn(@steps[2], 'teardown')

        @s.start()
        @s.next()
        @s.next()
        @s.next()

        expect(@steps[2].teardown.callCount).toEqual(1)

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

    describe 'events', ->
      it 'emits a start event', ->
        spy = jasmine.createSpy()
        @s.bind('start', spy)
        @s.start()
        expect(spy).toHaveBeenCalled()

      it 'emits a stop event', ->
        spy = jasmine.createSpy()
        @s.bind('stop', spy)
        @s.start()
        @s.next()
        @s.stop(false)
        expect(spy).toHaveBeenCalled()

BasicTourTests 'with Tourist.Tip.Simple', ->
  new Tourist.Tour
    stepOptions: @options
    steps: @steps
    cancelStep: @finalQuit
    successStep: @finalSucceed
    tipClass: 'Simple'
