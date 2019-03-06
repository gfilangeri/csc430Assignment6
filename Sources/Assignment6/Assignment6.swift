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

class NumC : ExprC {
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

enum ProgramError : Error {
    case wrongArity
    case wrongType
    case divByZero
}

func plus(vals : [Value]) -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return NumV(num: (n1.num + n2.num ))
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func mult(vals : [Value]) -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return NumV(num: (n1.num * n2.num ))
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func div(vals : [Value]) -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                if (n2.num != 0) {
                    return NumV(num: (n1.num / n2.num ))
                }
                throw ProgramError.divByZero
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func leq(vals : [Value]) -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return BoolV(b: (n1.num <= n2.num ))
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}


let top-env = Env(list: [EnvStruct(id: "true", val: BoolV(b: true)),
                         EnvStruct(id: "false", val: BoolV(b: false)),
                         EnvStruct(id: "+", val: PrimV(fn: plus)),
                         EnvStruct(id: "-", val: PrimV(fn: minus)),
                         EnvStruct(id: "*", val: PrimV(fn: mult)),
                         EnvStruct(id: "/", val: PrimV(fn: div)),
                         EnvStruct(id: "<=", val: PrimV(fn: leq)),
                         EnvStruct(id: "equal?", val: PrimV(fn: eq))])


func envLookup(env: Env, s: String) -> Value {
    for bind in env.list {
        if bind.id == s {
            return bind.val
        }
    }
}

func interp(e: ExprC, env: Env) -> Value {
    switch e {
    case is NumC:
        return NumV(num: e.num)
    case is IdC:
        return envLookup(env: env, s: e.id)
    case is StrC:
        return StrV(str: e.str)
    }
}


