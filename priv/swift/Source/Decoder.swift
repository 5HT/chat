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
    case "File":
        if body.count != 4 { return nil }
        let a_File = File()
            a_File.id = body[0].parse(bert: tuple.elements[1]) as? String
            a_File.mime = body[1].parse(bert: tuple.elements[2]) as? String
            a_File.payload = body[2].parse(bert: tuple.elements[3]) as? String
            a_File.parentid = body[3].parse(bert: tuple.elements[4]) as? String
        return a_File
    case "Message":
        if body.count != 8 { return nil }
        let a_Message = Message()
            a_Message.id = body[0].parse(bert: tuple.elements[1]) as? Int64
            a_Message.client_id = body[1].parse(bert: tuple.elements[2]) as? String
            a_Message.from = body[2].parse(bert: tuple.elements[3]) as? String
            a_Message.to = body[3].parse(bert: tuple.elements[4]) as? String
            a_Message.files = body[4].parse(bert: tuple.elements[5]) as? [File]
            a_Message.link = body[6].parse(bert: tuple.elements[7]) as? AnyObject
        return a_Message
    case "History":
        if body.count != 5 { return nil }
        let a_History = History()
            a_History.feed = body[0].parse(bert: tuple.elements[1]) as? AnyObject
            a_History.size = body[1].parse(bert: tuple.elements[2]) as? Int64
            a_History.entity_id = body[2].parse(bert: tuple.elements[3]) as? Int64
            a_History.data = body[3].parse(bert: tuple.elements[4]) as? Int64
        return a_History
    default: return nil
    }
}