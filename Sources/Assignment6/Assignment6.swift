class ExprC {}
class Value {}

struct EnvStruct {
    let id : String
    let val : Value
    
    init (id : String, val : Value) {
        self.id = id
        self.val = val
    }
}

class Env {
    let list : [EnvStruct]
    
    init (list : [EnvStruct]) {
        self.list = list
    }
}

class NumC : ExprC{
    let num : Float
    
    init (num : Float) {
        self.num = num
    }

}

class StrC : ExprC {
    let str : String
    
    init (str : String) {
        self.str = str
    }
}


class IdC : ExprC {
    let id : String
    
    init (id : String) {
        self.id = id
    }
}

class AppC : ExprC {
    let fn : ExprC
    let args : [ExprC]
    
    init (fn : ExprC, args : [ExprC]) {
        self.fn = fn
        self.args = args
    }
}

class IfC : ExprC {
    let ifStmnt : ExprC
    let thenStmnt : ExprC
    let elseStmnt : ExprC
    
    init (ifStmnt : ExprC, thenStmnt : ExprC, elseStmnt : ExprC) {
        self.ifStmnt = ifStmnt
        self.thenStmnt = thenStmnt
        self.elseStmnt = elseStmnt
    }
}

class LamC : ExprC {
    let param : [ExprC]
    let body : ExprC
    
    init (param : [ExprC], body : ExprC) {
        self.param = param
        self.body = body
    }
}

class NumV : Value {
    let num : Float
    
    init (num : Float) {
        self.num = num
    }
}

class StrV : Value {
    let str : String
    
    init (str : String) {
        self.str = str
    }
}

class CloV : Value {
    let param : [IdC]
    let body : ExprC
    let cloEnv : Env
    
    init (param : [IdC], body : ExprC, cloEnv : Env) {
        self.param = param
        self.body = body
        self.cloEnv = cloEnv
    }
}

class BoolV : Value {
    let b : Bool
    
    init (b : Bool) {
        self.b = b
    }
}

class PrimV : Value {
    let fn : (([Value]) -> Value)
    
    init (fn : @escaping (([Value]) -> Value)) {
        self.fn = fn
    }
}
