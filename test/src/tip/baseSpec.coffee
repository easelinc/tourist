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

BasicTipTests 'with Tourist.Tip.Simple', ->
  new Tourist.Tip.Simple
    model: @model
