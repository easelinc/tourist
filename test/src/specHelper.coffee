jasmine.getFixtures().fixturesPath = 'fixtures'
jasmine.getStyleFixtures().fixturesPath = 'fixtures'

beforeEach ->
  @addMatchers
    toShow: (exp) ->
      actual = this.actual
      actual.css('display') != 'none'

    toHide: (exp) ->
      actual = this.actual
      actual.css('display') == 'none'
