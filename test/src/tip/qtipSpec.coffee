BasicTipTests 'with Tourist.Tip.Simple', ->
  new Tourist.Tip.QTip
    model: @model

BasicTourTests 'with Tourist.Tip.Simple', ->
  new Tourist.Tour
    stepOptions: @options
    steps: @steps
    cancelStep: @finalQuit
    successStep: @finalSucceed
    tipClass: 'QTip'
