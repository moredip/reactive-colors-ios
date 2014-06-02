(function() {

  var busses = {};

  var busNamed = function(name){
    if( busses[name] == null ){
      busses[name] = new Bacon.Bus();
    }
    return busses[name];
  };

  var onObjcSignal = function(name,val){
    busNamed(name).push(val);
  }

  rxu.onObjcSignal = onObjcSignal;


  rxu.loaded( function(){
    console.log( "loaded root.js!" );

    busNamed('alpha-slider').onValue( function(val){
      console.log( "ALPHA: " + val );
    });
  });
})();
