(function() {
  var busses = {};

  var busNamed = function(name){
    if( busses[name] == null ){
      busses[name] = new Bacon.Bus();
    }
    return busses[name];
  };

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
})();
