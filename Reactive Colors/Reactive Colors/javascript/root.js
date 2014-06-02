rxu.loaded( function(){
  console.log( "loaded root.js!" );

  ['red-slider','blue-slider','green-slider','alpha-slider'].forEach( rxu.addTracingTo )

  var propertyStreams = {
    r: rxu.racSignal('red-slider').toProperty(1),
    g: rxu.racSignal('green-slider').toProperty(1),
    b: rxu.racSignal('blue-slider').toProperty(1),
    a: rxu.racSignal('alpha-slider').toProperty(1)
  };

  var colorStream = Bacon.combineTemplate( propertyStreams ).map( window.tinycolor.fromRatio );

  colorStream.onValue( function (tc){
    console.log( "color: " + tc.toRgbString() );
  });
  
});
