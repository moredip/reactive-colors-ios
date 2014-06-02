console.log("booted!");
console.log("2 + 2 = " + (2+2));

rxu.somethingChanged = function(){
  console.log( "something changed!" );
};

rxu.onObjcSignal = function(name,val){
  console.log( "SIGNAL "+name+": " + val);
}