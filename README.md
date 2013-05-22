Tourist.js is a simple library for creating guided tours through your app.
It's better suited to complex, single-page apps than websites. One of our main
requirements was the ability to control the interface for each step. For
example, a step in the tour might need to open a window or menu to work
correctly. Tourist gives you hooks to do this.

Basically, you specify a series of steps which explain elements to point at
and what to say. Tourist.js manages moving between those steps.

## Install

The code is available via `bower install tourist`. Once you have the code, you just need to include the javascript file. An optional CSS file with minimal styling is included as well.

```
<script src="tourist.js"></script>

<!-- Optional! -->
<link rel="stylesheet" href="../tourist.css" type="text/css" media="screen">
```

## Dependencies

Tourist depends on Backbone and jQuery.

Tourist comes with the ability to use either Bootstrap popovers (default) or QTip2 tips, so you'll need either Bootstrap CSS (only the CSS is necessary!) or QTip2 installed. You can write your own tooltip connector if you'd like.

## Basic Usage

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

The 'step object' is a simple js obj that specifies how a step will behave.

A simple Example of a step object:

```javascript
{
  content: '<p>Welcome to my step</p>'
  target: $('#something-to-point-at')
  closeButton: true
  highlightTarget: true
  setup: (tour, options) ->
    # do stuff in the interface/bind
  teardown: (tour, options) ->
    # remove stuff/unbind
}
```

### Step object options

* `content` a string of html to put into the step.
* `target` jquery object or absolute point: [10, 30]
* `highlightTarget` optional bool, true will outline the target with a bright color.
* `container` optional jquery element that should contain the step flyout.
              default: $('body')
* `viewport` optional jquery element that the step flyout should stay within.
             $(window) is commonly used. default: false
* `my` string position of the pointer on the tip. default: 'left center'
* `at` string position on the element the tip points to. default: 'right center' see http://craigsworks.com/projects/qtip2/docs/position/#basics

### Step object button options

* `okButton` optional bool, true will show a 'primary' ok button
* `closeButton` optional bool, true will show a close button in the top right corner
* `skipButton` optional bool, true will show a 'secondary' skip button
* `nextButton` optional bool, true will show a 'primary' next button

### Step object function options

All functions on the step will have the signature `function(tour, options){}` where

* `tour` is the Draw.Tour object. Handy to call tour.next()
* `options` is the step options. An object passed into the tour when created.
            It has the environment that the fns can use to manipulate the
            interface, bind to events, etc. The same object is passed to all
            of a step object's functions, so it is handy for passing data
            between steps.

Onto the options:

#### setup()

`setup()` is called before a step is shown. Use it to scroll to your target, hide/show things, etc.

`this` is the step object itself.

`setup()` can return an object. Properties in the returned object will override
properties in the step object.

Example, the target might be dynamic so you would specify:

```javascript
{
  setup: function(tour, options) {
    options.model.bind('change:thing', @onThingChange);
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
    options.model.unbind('change:thing', @onThingChange);
  }
}
```

Return nothing from `teardown()`

#### bind

`bind` is an array of function names to bind. Use this for event handlers you use in `setup()`.

Will bind functions to the step object as this, and the first 2 args as tour and options. i.e.

```javascript
{
  bind: ['onChangeSomething'],
  onChangeSomething: function(tour, options, model, value) {
    tour.next()
  },
  setup: function(tour, options) {
    options.document.bind('change:something', @onChangeSomething);
    return {};
  },
  teardown: function(tour, options) {
    options.document.unbind('change:something', @onChangeSomething)
  }
}
```

## Testing/Building

* uses coffeescript
  * [install coffeescript][install]
  * `make watch` and `make test-watch`
* start a webserver at the root. I use `python -m SimpleHTTPServer 8080`
* visit http://localhost:8080/test/suite.html

## Structure

* /test/src - coffeescript jasmine tests
* /test/suite - runs the tests
* /src - coffeescript
* tourist.js - generated js

## Contributing

* adhere to our [styleguide][styleguide]
* Send a pull request.
* Write tests. New untested code will not be merged.

MIT License

[jasmine]: http://pivotal.github.com/jasmine/
[install]: http://jashkenas.github.com/coffee-script/#installation
[skeleton]: http://buttersafe.com/2008/03/13/romance-on-the-floating-island/
[styleguide]: https://github.com/easelinc/coffeescript-style-guide