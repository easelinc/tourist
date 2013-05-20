
BasicTipTests 'with Tourist.Tip.Bootstrap', ->
  new Tourist.Tip.Bootstrap
    model: @model

BasicTourTests 'with Tourist.Tip.Bootstrap', ->
  new Tourist.Tour
    stepOptions: @options
    steps: @steps
    cancelStep: @finalQuit
    successStep: @finalSucceed
    tipClass: 'Bootstrap'

describe "Tourist.Tip.Bootstrap", ->
  beforeEach ->
    loadFixtures('tour.html')

    @model = new Tourist.Model()
    @s = new Tourist.Tip.Bootstrap
      model: @model

  afterEach ->
    @s.destroy()

  describe 'hide/show', ->
    it 'slidein effect runs', ->
      spyOn(Tourist.Tip.Bootstrap.effects, 'slidein').andCallThrough()
      @s.options.showEffect = 'slidein'
      el = $('#target-one')
      @s.tip.setPosition(el, 'top center', 'bottom center')
      @s.show()
      expect(Tourist.Tip.Bootstrap.effects.slidein).toHaveBeenCalled()

    it 'show works with an effect', ->
      Tourist.Tip.Bootstrap.effects.showeff = jasmine.createSpy()

      @s.options.showEffect = 'showeff'
      @s.show()

      expect(Tourist.Tip.Bootstrap.effects.showeff).toHaveBeenCalled()

    it 'hide works with an effect', ->
      Tourist.Tip.Bootstrap.effects.hideeff = jasmine.createSpy()

      @s.options.hideEffect = 'hideeff'
      @s.hide()

      expect(Tourist.Tip.Bootstrap.effects.hideeff).toHaveBeenCalled()

# Only test the basic things here. Positioning of the popover and the arrow is
# hard to test in code. There is an html file in examples/bootstrap-position-
# test.html to test all the positions.
describe "Tourist.Tip.BootstrapTip", ->
  beforeEach ->
    loadFixtures('tour.html')

    @s = new Tourist.Tip.BootstrapTip()

  afterEach ->
    @s.destroy()

  describe 'hide/show', ->
    it 'initially hidden', ->
      expect(@s.el).toHide()

    it 'hide works', ->
      @s.show()
      @s.hide()
      expect(@s.el).toHide()

    it 'show works', ->
      @s.show()
      expect(@s.el).toShow()

  describe 'positioning', ->
    it 'setPosition will not show the tip', ->
      expect(@s.el).toHide()

      el = $('#target-one')
      @s.setPosition(el, 'top center', 'bottom center')

      expect(@s.el).toHide()

    it 'setPosition keeps the tip shown', ->
      @s.show()

      el = $('#target-one')
      @s.setPosition(el, 'top center', 'bottom center')

      expect(@s.el).toShow()
