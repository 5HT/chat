func get_Log() -> Model {
  return Model(value:Tuple(name:"Log",body:[
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        get_p2p(),
        get_muc()])),
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Number())])),
    Model(value:List(constant:nil,model:get_Msg())),
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Number())]))]))}
