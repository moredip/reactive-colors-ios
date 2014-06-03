(function() {
  var busses = {};
  var sinkSignals = {};

  var busNamed = function(name){
    if( busses[name] == null ){
      busses[name] = new Bacon.Bus();
    }
    return busses[name];
  };

  var registerSinkSignalHandler = function(name,sinkSignalHandler){
    console.log("registering signal handler: "+name);
    sinkSignals[name] = sinkSignalHandler;
  }

  var wireStreamToSink = function(sinkName,stream){
    stream.onValue( function(value){
      var signalHandler = sinkSignals[sinkName];
      if( signalHandler == null ){
        console.log( "ERROR: no sink signal handler named: "+sinkName );
      }else{
        signalHandler(value);
      }
    });
  }

  var onObjcSignal = function(signalName,val){
    busNamed(signalName).push(val);
  }

  var addTracingTo = function(signalName){
    busNamed(signalName).onValue( function(val){
      console.log("SIGNAL "+signalName+": "+val);
    });
  }

  rxu.onObjcSignal = onObjcSignal;
  rxu.racSignal = busNamed;
  rxu.addTracingTo = addTracingTo;
  rxu.registerSinkSignalHandler = registerSinkSignalHandler;
  rxu.wireStreamToSink = wireStreamToSink
})();
