busses = {}
sinkSignals = {}

busNamed = (name)->
  busses[name] ?= new Bacon.Bus()

registerSinkSignalHandler = (name,sinkSignalHandler)->
  console.log( "registering signal handler: #{name}" )
  sinkSignals[name] = sinkSignalHandler

wireStreamToSink = (sinkName,stream)->
  stream.onValue (value)->
    signalHandler = sinkSignals[sinkName]
    if signalHandler? 
      signalHandler(value)
    else
      console.log( "ERROR: no sink signal handler named: #{sinkName}" )

onObjcSignal = (signalName,val)->
  busNamed(signalName).push(val)

addTracingTo = (signalName)->
  busNamed(signalName).onValue (val)->
    console.log("SIGNAL #{signalName}: #{val}")

rxu.onObjcSignal = onObjcSignal
rxu.racSignal = busNamed
rxu.addTracingTo = addTracingTo
rxu.registerSinkSignalHandler = registerSinkSignalHandler
rxu.wireStreamToSink = wireStreamToSink
