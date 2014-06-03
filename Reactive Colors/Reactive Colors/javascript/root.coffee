rxu.loaded ->
  #['red-slider','blue-slider','green-slider','alpha-slider'].forEach( rxu.addTracingTo )

  propertyStreams = {
    r: rxu.racSignal('red-slider').toProperty(1)
    g: rxu.racSignal('green-slider').toProperty(1)
    b: rxu.racSignal('blue-slider').toProperty(1)
    a: rxu.racSignal('alpha-slider').toProperty(1)
  }

  colorStream = Bacon.combineTemplate( propertyStreams ).map( window.tinycolor.fromRatio )

  colorDictStream = colorStream.map (tc)->
    rgb = tc.toRgb()
    {
      r: (rgb.r / 255)
      g: (rgb.g / 255)
      b: (rgb.b / 255)
      a: rgb.a
    }

  rxu.wireStreamToSink( "color-dict", colorDictStream )
