tinycolor = window.tinycolor

keyedStream = (stream,key)->
  stream.map (v)->
    obj = {}
    obj[key] = v
    obj

keyStreams = (streamsDict)->
  result = {}
  for key,stream of streamsDict
    result[key] = keyedStream(stream,key)
  result

mergedChangeStreams = (streams)->
  changeStreams = (stream.changes() for name,stream of streams)
  Bacon.mergeAll(changeStreams)

rgbInputStreamFromKeyedStreams = (keyedStreams)->
  rgbStreams = _.pick(keyedStreams,"r","g","b")
  mergedChangeStreams(rgbStreams)

hslInputStreamFromKeyedStreams = (keyedStreams)->
  hslStreams = _.pick(keyedStreams,"h","s","l")
  mergedChangeStreams(hslStreams)

masterColorStreamFromInputSliders = (sliders)->
  sharedMasterColor = tinycolor("#aabbcc")
  masterColorBus = new Bacon.Bus()

  keyedSliders = keyStreams(sliders)

  rgbInputStream = rgbInputStreamFromKeyedStreams(keyedSliders)
  hslInputStream = hslInputStreamFromKeyedStreams(keyedSliders)

  rgbInputStream.onValue (rgb)->
    sharedMasterColor = tinycolor( _.defaults( rgb, sharedMasterColor.toRgb() ) )
    masterColorBus.push(sharedMasterColor)

  hslInputStream.onValue (hsl)->
    sharedMasterColor = tinycolor( _.defaults( hsl, sharedMasterColor.toHsl() ) )
    masterColorBus.push(sharedMasterColor)

  masterColorBus.toProperty(sharedMasterColor)


rxu.loaded ->
  #['red-slider','blue-slider','green-slider','alpha-slider'].forEach( rxu.addTracingTo )

  timesTwoFiveFive = (x) -> x*256

  sliderStreams = {
    r: rxu.racSignal('red-slider').toProperty(1).map(timesTwoFiveFive)
    g: rxu.racSignal('green-slider').toProperty(1).map(timesTwoFiveFive)
    b: rxu.racSignal('blue-slider').toProperty(1).map(timesTwoFiveFive)

    h: rxu.racSignal('hue-slider').toProperty(1)
    s: rxu.racSignal('saturation-slider').toProperty(1)
    l: rxu.racSignal('lightness-slider').toProperty(1)

    a: rxu.racSignal('alpha-slider').toProperty(1)
  }
  colorStream = masterColorStreamFromInputSliders( sliderStreams )

  rgbRatios = colorStream.map (c)->
    rgb = c.toRgb()
    {
      r: (rgb.r / 256)
      g: (rgb.g / 256)
      b: (rgb.b / 256)
      a: rgb.a
    }
  rxu.wireStreamToSink( "color-dict", rgbRatios )

  rxu.wireStreamToSink( "red-slider", rgbRatios.map( (rgb)-> rgb.r ) )
  rxu.wireStreamToSink( "green-slider", rgbRatios.map( (rgb)-> rgb.g ) )
  rxu.wireStreamToSink( "blue-slider", rgbRatios.map( (rgb)-> rgb.b ) )


  rgbPerc = colorStream.map (c)->c.toPercentageRgb()

  rxu.wireStreamToSink( "red-label", rgbPerc.map( (rgbPerc)-> rgbPerc.r ) )
  rxu.wireStreamToSink( "green-label", rgbPerc.map( (rgbPerc)-> rgbPerc.g ) )
  rxu.wireStreamToSink( "blue-label", rgbPerc.map( (rgbPerc)-> rgbPerc.b ) )


  hsl = colorStream.map (c)->c.toHsl()

  rxu.wireStreamToSink( "hue-slider", hsl.map( (hsl)-> hsl.h ) )
  rxu.wireStreamToSink( "saturation-slider", hsl.map( (hsl)-> hsl.s ) )
  rxu.wireStreamToSink( "lightness-slider", hsl.map( (hsl)-> hsl.l ) )
  
  rxu.wireStreamToSink( "hue-label", hsl.map( (hsl)-> hsl.h.toFixed() ) )
  rxu.wireStreamToSink( "saturation-label", hsl.map( (hsl)-> hsl.s.toFixed(2) ) )
  rxu.wireStreamToSink( "lightness-label", hsl.map( (hsl)-> hsl.l.toFixed(2) ) )
