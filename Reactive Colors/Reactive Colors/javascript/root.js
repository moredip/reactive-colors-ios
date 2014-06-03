(function() {
  var hslInputStreamFromKeyedStreams, keyStreams, keyedStream, masterColorStreamFromInputSliders, mergedChangeStreams, rgbInputStreamFromKeyedStreams, tinycolor;

  tinycolor = window.tinycolor;

  keyedStream = function(stream, key) {
    return stream.map(function(v) {
      var obj;
      obj = {};
      obj[key] = v;
      return obj;
    });
  };

  keyStreams = function(streamsDict) {
    var key, result, stream;
    result = {};
    for (key in streamsDict) {
      stream = streamsDict[key];
      result[key] = keyedStream(stream, key);
    }
    return result;
  };

  mergedChangeStreams = function(streams) {
    var changeStreams, name, stream;
    changeStreams = (function() {
      var _results;
      _results = [];
      for (name in streams) {
        stream = streams[name];
        _results.push(stream.changes());
      }
      return _results;
    })();
    return Bacon.mergeAll(changeStreams);
  };

  rgbInputStreamFromKeyedStreams = function(keyedStreams) {
    var rgbStreams;
    rgbStreams = _.pick(keyedStreams, "r", "g", "b");
    return mergedChangeStreams(rgbStreams);
  };

  hslInputStreamFromKeyedStreams = function(keyedStreams) {
    var hslStreams;
    hslStreams = _.pick(keyedStreams, "h", "s", "l");
    return mergedChangeStreams(hslStreams);
  };

  masterColorStreamFromInputSliders = function(sliders) {
    var hslInputStream, keyedSliders, masterColorBus, rgbInputStream, sharedMasterColor;
    sharedMasterColor = tinycolor("#aabbcc");
    masterColorBus = new Bacon.Bus();
    keyedSliders = keyStreams(sliders);
    rgbInputStream = rgbInputStreamFromKeyedStreams(keyedSliders);
    hslInputStream = hslInputStreamFromKeyedStreams(keyedSliders);
    rgbInputStream.onValue(function(rgb) {
      sharedMasterColor = tinycolor(_.defaults(rgb, sharedMasterColor.toRgb()));
      return masterColorBus.push(sharedMasterColor);
    });
    hslInputStream.onValue(function(hsl) {
      sharedMasterColor = tinycolor(_.defaults(hsl, sharedMasterColor.toHsl()));
      return masterColorBus.push(sharedMasterColor);
    });
    return masterColorBus.toProperty(sharedMasterColor);
  };

  rxu.loaded(function() {
    var colorStream, hsl, rgb, rgbPerc, rgbRatios, sliderStreams;
    sliderStreams = {
      r: rxu.racSignal('red-slider').toProperty(1),
      g: rxu.racSignal('green-slider').toProperty(1),
      b: rxu.racSignal('blue-slider').toProperty(1),
      h: rxu.racSignal('hue-slider').toProperty(1),
      s: rxu.racSignal('saturation-slider').toProperty(1),
      l: rxu.racSignal('lightness-slider').toProperty(1),
      a: rxu.racSignal('alpha-slider').toProperty(1)
    };
    colorStream = masterColorStreamFromInputSliders(sliderStreams);
    rgbRatios = colorStream.map(function(tc) {
      var rgb;
      rgb = tc.toRgb();
      return {
        r: rgb.r / 255,
        g: rgb.g / 255,
        b: rgb.b / 255,
        a: rgb.a
      };
    });
    rxu.wireStreamToSink("color-dict", rgbRatios);
    rgb = colorStream.map(function(c) {
      return c.toRgb();
    });
    rxu.wireStreamToSink("red-slider", rgb.map(function(rgb) {
      return rgb.r;
    }));
    rxu.wireStreamToSink("green-slider", rgb.map(function(rgb) {
      return rgb.g;
    }));
    rxu.wireStreamToSink("blue-slider", rgb.map(function(rgb) {
      return rgb.b;
    }));
    rgbPerc = colorStream.map(function(c) {
      return c.toPercentageRgb();
    });
    rxu.wireStreamToSink("red-label", colorStream.map(function(rgbPerc) {
      return rgbPerc.r;
    }));
    rxu.wireStreamToSink("green-label", colorStream.map(function(rgbPerc) {
      return rgbPerc.g;
    }));
    rxu.wireStreamToSink("blue-label", colorStream.map(function(rgbPerc) {
      return rgbPerc.b;
    }));
    hsl = colorStream.map(function(c) {
      return c.toHsl();
    });
    rxu.wireStreamToSink("hue-slider", hsl.map(function(hsl) {
      return hsl.h;
    }));
    rxu.wireStreamToSink("saturation-slider", hsl.map(function(hsl) {
      return hsl.s;
    }));
    rxu.wireStreamToSink("lightness-slider", hsl.map(function(hsl) {
      return hsl.l;
    }));
    rxu.wireStreamToSink("hue-label", hsl.map(function(hsl) {
      return hsl.h.toFixed();
    }));
    rxu.wireStreamToSink("saturation-label", hsl.map(function(hsl) {
      return hsl.s.toFixed(2);
    }));
    return rxu.wireStreamToSink("lightness-label", hsl.map(function(hsl) {
      return hsl.l.toFixed(2);
    }));
  });

}).call(this);
