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

```
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

## The step object

The 'step object' is a simple js obj that specifies how the step will behave.

A simple Example of a step object:

```
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

  All functions on the step will have the signature '(tour, options) ->'

    tour - the Draw.Tour object. Handy to call tour.next()
    options - the step options. An object passed into the tour when created.
              It has the environment that the fns can use to manipulate the
              interface, bind to events, etc. The same object is passed to all
              of a step object's functions, so it is handy for passing data
              between steps.

  setup - called before step is shown. Use to scroll to your target, hide/show things, ...

    'this' is the step object itself.

    MUST return an object. Properties in the returned object will override
    properties in the step object.

    i.e. the target might be dynamic so you would specify:

    setup: (tour, options) ->
      return { target: $('#point-to-me') }

  teardown - function called right before hiding the step. Use to unbind from
    things you bound to in setup().

    'this' is the step object itself.

    Return nothing.

  bind - an array of function names to bind. Use this for event handlers you use in setup().

    Will bind functions to the step object as this, and the first 2 args as tour and options.

    i.e.

    bind: ['onChangeSomething']
    setup: (tour, options) ->
      options.document.bind('change:something', @onChangeSomething)
    onChangeSomething: (tour, options, model, value) ->
      tour.next()
    teardown: (tour, options) ->
      options.document.unbind('change:something', @onChangeSomething)


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