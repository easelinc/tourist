jasmine.getFixtures().fixturesPath = 'test/fixtures'
jasmine.getStyleFixtures().fixturesPath = 'test/fixtures'

beforeEach ->
  @addMatchers
    toShow: (exp) ->
      actual = this.actual
      actual.css('display') != 'none'

    toHide: (exp) ->
      actual = this.actual
      actual.css('display') == 'none'
