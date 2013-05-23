window.BasicTipTests = (description, tipGenerator) ->
  describe "Tourist.Tip #{description}", ->
    beforeEach ->
      loadFixtures('tour.html')

      @model = new Tourist.Model
        current_step: null

      @s = tipGenerator.call(this)

    afterEach ->
      Tourist.Tip.Base.destroy()

    describe 'basics', ->
      it 'inits', ->
        expect(@s.options.model instanceof Tourist.Model).toEqual(true)

    describe 'setTarget()', ->
      it 'will set the @target', ->
        el = $('#target-one')
        @s.setTarget(el, {})
        expect(@s.target).toEqual(el)

      it 'will highlight the @target', ->
        el = $('#target-one')
        @s.setTarget(el, {highlightTarget: true})
        expect(el).toHaveClass(@s.highlightClass)

      it 'will highlight the @target', ->
        el = $('#target-one')
        @s.setTarget(el, {highlightTarget: false})
        expect(el).not.toHaveClass(@s.highlightClass)


BasicTipTests 'with Tourist.Tip.Simple', ->
  new Tourist.Tip.Simple
    model: @model
