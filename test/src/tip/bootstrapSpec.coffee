
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

xdescribe "Tourist.Tip.Bootstrap specific", ->
  beforeEach ->
    loadFixtures('tour.html')

    @model = new Tourist.Model
      current_step: null

    @s = new Tourist.Tip.Bootstrap
      model: @model

  afterEach ->
    Tourist.Tip.Base.destroy()

  describe 'setTarget()', ->
    it 'will set the @target', ->
      el = $('#target-one')
      @s.setTarget(el, {})

      target = @s.qtip.get('position.target')
      expect(target).toEqual(el)

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
