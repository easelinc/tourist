# Tourist.js [![Build Status](https://travis-ci.org/easelinc/tourist.png)](https://travis-ci.org/easelinc/tourist)


Tourist.js is a simple library for creating guided tours through your app.
It's better suited to complex, single-page apps than websites. One of our main
requirements was the ability to control the interface for each step. For
example, a step in the tour might need to open a window or menu to work
correctly. Tourist gives you hooks to do this.

Basically, you specify a series of steps which explain elements to point at
and what to say. Tourist.js manages moving between those steps.

### Install

The code is available via `bower install tourist`. Once you have the
code, you just need to include the javascript file. An optional CSS file
with minimal styling is included as well.

```html
<script src="tourist.js"></script>

<!-- Optional! -->
<link rel="stylesheet" href="tourist.css" type="text/css" media="screen">
```

### Dependencies

Tourist depends on Backbone and jQuery. jQuery UI is optional. Tourist
uses an easing function from jQuery UI if present in the show effect
with the Bootstrap tip implementation.

Tourist comes with the ability to use either [Bootstrap 3 popovers][popovers]
(default) or [QTip2][qtip2] tips, so you'll need either Bootstrap 3 CSS
(only the CSS is necessary!) or QTip2 installed.  You can write your own
tooltip connector if you'd like.

### Basic Usage

Making a simple tour is easy:

```javascript
var steps = [{
  // this is a step object
  content: '<p>Hey user, check this out!</p>',
  highlightTarget: true,
  nextButton: true,
  target: $('#thing1'),
  my: 'bottom center',
  at: 'top center'
}, {
  ...
}, ...]

var tour = new Tourist.Tour({
  steps: steps,
  tipOptions:{ showEffect: 'slidein' }
});
tour.start();
```

# Reference

## Tour object

Create one like this:

```javascript
var steps = [{...}, {...}]
var tour = new Tourist.Tour({
  steps: steps
});
tour.start();
```

### Options

* `steps` a collection of step objects
* `stepOptions` an object of options to be passed to each function called on a step object, notably the `setup()` and `teardown()` functions
* `tipClass` the class from the `Tourist.Tip` namespace to use. Defaults to `Bootstrap`, you can use `QTip` if you have QTip2 installed
* `tipOptions` an options object passed to the `tipClass` on creation
* `cancelStep` step object for a step that runs if user hits the close button.
* `successStep` step object for a step that runs last when they make it all the way through.

### Methods

* `start()` will start the tour. Can be used to restart a stopped tour
* `stop(doFinalStep)` will stop the tour. doFinalStep is a bool; `true` will run the `cancelStep` specified in the options (if it's specified).
* `next()` move to the next step

## The step object

The 'step object' is a simple javascript object that specifies how a step will behave.

A simple Example of a step object:

```javascript
{
  content: '<p>Welcome to my step</p>',
  target: $('#something-to-point-at'),
  closeButton: true,
  highlightTarget: true,
  setup: (tour, options) {
    // do stuff in the interface/bind
  },
  teardown: function(tour, options) {
    // remove stuff/unbind
  }
}
```

### Step object options

* `content` a string of html to put into the step.
* `target` jQuery object or absolute point: [10, 30]
* `highlightTarget` optional bool, true will add the class `tour-highlight` to the target. If tourist.css is included, it will outline the target with a bright color.
* `container` optional jQuery element that should contain the step flyout.
              default: $('body')
* `viewport` optional jQuery element that the step flyout should stay within.
             $(window) is commonly used. default: false
* `zIndex` optional string or number z-index value for the tip. If not specified, will use
           value specified in css (or base tip implementation in case of QTip2 tips).
           Value set on prev step will not affect later steps.
* `my` string position of the pointer on the tip. default: 'left center'
* `at` string position on the element the tip points to. default: 'right center' see http://craigsworks.com/projects/qtip2/docs/position/#basics
* `okButton` optional bool, true will show a 'primary' ok button
* `closeButton` optional bool, true will show a close button in the top right corner
* `skipButton` optional bool, true will show a 'secondary' skip button
* `nextButton` optional bool, true will show a 'primary' next button
* `setup` optional function called before the tip is shown; see [setup](#setup) section
* `teardown` optional function called when the tour moves to the next step; see [teardown](#teardown) section
* `bind` optional list of function names to bind; see [bind](#bind) section

### Step object function options

All functions on the step will have the signature `function(tour, options){}` where

* `tour` is the Draw.Tour object. Handy to call tour.next()
* `options` is the step options. An object passed into the tour when created.
            It has the environment that the fns can use to manipulate the
            interface, bind to events, etc. The same object is passed to all
            of a step object's functions, so it is handy for passing data
            between steps.

#### setup()

`setup()` is called before a step is shown. Use it to scroll to your
target, hide/show things, etc.

`this` is the step object itself.

`setup()` can return an object. Properties in the returned object will override
properties in the step object.

Example, the target might be dynamic so you would specify:

```javascript
{
  setup: function(tour, options) {
    options.model.bind('change:thing', this.onThingChange);
    return { target: $('#point-to-me') };
  }
}
```

#### teardown()

`teardown()` will be called right before hiding the step. Use to unbind from
things you bound to in setup().

`this` is the step object itself.

```javascript
{
  teardown: function(tour, options) {
    options.model.unbind('change:thing', this.onThingChange);
  }
}
```

Return nothing from `teardown()`

#### bind

`bind` is an array of function names to bind. Use this for event
handlers you use in `setup()`.

Will bind functions to the step object as this, and the first 2 args as
tour and options. i.e.

```javascript
{
  bind: ['onChangeSomething'],
  onChangeSomething: function(tour, options, model, value) {
    tour.next()
  },
  setup: function(tour, options) {
    options.document.bind('change:something', this.onChangeSomething);
    return {};
  },
  teardown: function(tour, options) {
    options.document.unbind('change:something', this.onChangeSomething)
  }
}
```

## Tip objects

You won't be creating `Tip` objects yourself, the `Tour` object will handle
that. But you can choose which tip implementation to use and you can pass the
tip options to use on creation.

### Bootstrap tips

Bootstrap tips are the default tip. They use only the markup and CSS from
Bootstrap. Bootstrap's javascript for tooltips or popovers is not necessary.
Here's how to use them.

```javascript
var tour = new Tourist.Tour({
  steps: steps,
  tipClass: 'Bootstrap'
  tipOptions: {
    showEffect: 'slidein'
  }
});
```

It supports some options you can specify in `tipOptions`:

* `showEffect` a string effect name
* `hideEffect` a string effect name

Only one effect is defined at this time: `slidein`. And you need to include
jQuery UI to get the proper easing function for it.

Effects are specified as functions on `Tourist.Tip.Bootstrap.effects`
take a look at the implementation for [an existing effect][booteffect] to get
an idea how to extend.

### QTip2 tips

An alternative is to use QTip2 tips. You need to include both the QTip
javascript and CSS for these to work.

```javascript
var tour = new Tourist.Tour({
  steps: steps,
  tipClass: 'QTip'
  tipOptions: {
    ...
  }
});
```

Options accepted are any options QTip supports and in their format.

### Your own Tip implementation

You can use your own tip implementation if you want. Make a class and
hang it off the `Tourist.Tip` namespace. See [the tips code][tipscode]
for examples. The [bootstrap example][bootstraptip] is probably most
interesting. Here is a basic example in coffeescript:

```coffeescript
# you need to provide these implementations at a minimum
class Tourist.Tip.MyTip extends Tourist.Tip.Base
  initialize: (options) ->
    # options would be: { likes: ['turtles'] }
    $('body').append(@el)

  show: ->
    @el.show()

  hide: ->
    @el.hide()

  _getTipElement: ->
    @el

  # Jam the content into our element
  _renderContent: (step, contentElement) ->
    @el.html(contentElement)

tour = new Tourist.Tour
  steps: steps
  tipClass: 'MyTip'
  tipOptions: { likes: ['turtles'] }
```

## Testing/Building

* Requires grunt `npm install -g grunt-cli`
* Install grunt modules `npm install`
* Automatically compile changes `grunt watch`
* Run tests with grunt `grunt test`

## Browser support

Officially tested on latest Firefox and Chrome


## Structure

* /test/src - coffeescript jasmine tests
* /test/suite - runs the tests
* /src - coffeescript
* tourist.js - generated js

## Contributing

* Adhere to our [styleguide][styleguide]
* Send a pull request.
* Write tests. New untested code will not be merged.

## Release History

* `major.minor.patch`: yyyy.mm.dd - description
* `0.0.12`: 2013-06-12 - add zIndex step object option

MIT License

[jasmine]: https://jasmine.github.io/
[install]: http://jashkenas.github.com/coffee-script/#installation
[skeleton]: http://buttersafe.com/2008/03/13/romance-on-the-floating-island/
[styleguide]: https://github.com/easelinc/coffeescript-style-guide

[qtip2]: http://craigsworks.com/projects/qtip2/
[popovers]: http://getbootstrap.com/javascript/#popovers
[booteffect]: https://github.com/easelinc/tourist/blob/master/src/tip/bootstrap.coffee#L64
[tipscode]: https://github.com/easelinc/tourist/tree/master/src/tip
[bootstraptip]: https://github.com/easelinc/tourist/blob/master/src/tip/bootstrap.coffee
