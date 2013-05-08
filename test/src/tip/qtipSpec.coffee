BasicTipTests 'with Tourist.Tip.QTip', ->
  new Tourist.Tip.QTip
    model: @model

BasicTourTests 'with Tourist.Tip.QTip', ->
  new Tourist.Tour
    stepOptions: @options
    steps: @steps
    cancelStep: @finalQuit
    successStep: @finalSucceed
    tipClass: 'QTip'

describe "Tourist.Tip.QTip specific", ->
  beforeEach ->
    loadFixtures('tour.html')

    @model = new Tourist.Model
      current_step: null

    @s = new Tourist.Tip.QTip
      model: @model

  afterEach ->
    Tourist.Tip.Base.destroy()

  describe 'setTarget()', ->
    it 'will set the @target', ->
      el = $('#target-one')
      @s.setTarget(el, {})

      target = @s.qtip.get('position.target')
      expect(target).toEqual(el)