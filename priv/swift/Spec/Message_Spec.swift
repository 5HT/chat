func get_Message() -> Model {
  return Model(value:Tuple(name:"Message",body:[
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Number())])),
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Binary())])),
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Binary())])),
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Binary())])),
    Model(value:List(constant:nil,model:get_File())),
    Model(value:Chain(types:[
        Model(value:List(constant:"")),
        Model(value:Number()),
        get_Message()]))]))}
