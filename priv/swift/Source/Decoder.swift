func parseObject(name: String, body:[Model], tuple: BertTuple) -> AnyObject?
{
    switch name {
    case "muc":
        if body.count != 1 { return nil }
        let a_muc = muc()
            a_muc.name = body[0].parse(bert: tuple.elements[1]) as? String
        return a_muc
    case "p2p":
        if body.count != 2 { return nil }
        let a_p2p = p2p()
            a_p2p.from = body[0].parse(bert: tuple.elements[1]) as? String
            a_p2p.to = body[1].parse(bert: tuple.elements[2]) as? String
        return a_p2p
    case "Ack":
        if body.count != 2 { return nil }
        let a_Ack = Ack()
            a_Ack.id = body[0].parse(bert: tuple.elements[1]) as? Int64
            a_Ack.table = body[1].parse(bert: tuple.elements[2]) as? StringAtom
        return a_Ack
    case "Bin":
        if body.count != 4 { return nil }
        let a_Bin = Bin()
            a_Bin.id = body[0].parse(bert: tuple.elements[1]) as? String
            a_Bin.mime = body[1].parse(bert: tuple.elements[2]) as? String
            a_Bin.payload = body[2].parse(bert: tuple.elements[3]) as? String
            a_Bin.parentid = body[3].parse(bert: tuple.elements[4]) as? String
        return a_Bin
    case "Msg":
        if body.count != 6 { return nil }
        let a_Msg = Msg()
            a_Msg.id = body[0].parse(bert: tuple.elements[1]) as? Int64
            a_Msg.client_id = body[1].parse(bert: tuple.elements[2]) as? String
            a_Msg.from = body[2].parse(bert: tuple.elements[3]) as? String
            a_Msg.to = body[3].parse(bert: tuple.elements[4]) as? String
            a_Msg.files = body[4].parse(bert: tuple.elements[5]) as? [Bin]
            a_Msg.type = body[5].parse(bert: tuple.elements[6]) as? StringAtom
        return a_Msg
    case "Log":
        if body.count != 4 { return nil }
        let a_Log = Log()
            a_Log.feed = body[0].parse(bert: tuple.elements[1]) as? AnyObject
            a_Log.id = body[1].parse(bert: tuple.elements[2]) as? Int64
            a_Log.data = body[2].parse(bert: tuple.elements[3]) as? [Msg]
            a_Log.length = body[3].parse(bert: tuple.elements[4]) as? Int64
        return a_Log
    default: return nil
    }
}