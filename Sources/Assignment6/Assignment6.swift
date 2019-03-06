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
    let fn : (([Value]) throws -> Value)
    
    init (fn : @escaping (([Value]) throws -> Value)) {
        self.fn = fn
    }
}

enum ProgramError : Error {
    case wrongArity
    case wrongType
    case divByZero
    case wrongAppC
    case wrongExprC
    case notInEnv
}

func plus(vals : [Value]) throws -> Value {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return NumV(num: (n1.num + n2.num))
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func minus(vals : [Value]) throws -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return NumV(num: (n1.num - n2.num))
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func mult(vals : [Value]) throws -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return NumV(num: (n1.num * n2.num))
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func div(vals : [Value]) throws -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                if n2.num != 0 {
                    return NumV(num: (n1.num / n2.num))
                }
                throw ProgramError.divByZero
            }
        }
        throw ProgramError.wrongType
    }
    throw ProgramError.wrongArity
}

func leq(vals : [Value]) throws -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return BoolV(b: (n1.num <= n2.num ))
            }
        }
    }
    throw ProgramError.wrongType
}

func eq(vals : [Value]) throws -> Value  {
    if vals.count == 2 {
        if let n1 = vals[0] as? NumV {
            if let n2 = vals[1] as? NumV {
                return BoolV(b: (n1.num == n2.num))
            }
        }
        if let b1 = vals[0] as? BoolV {
            if let b2 = vals[1] as? BoolV{
                return BoolV(b: (b1.b == b2.b))
            }
        }
        if let s1 = vals[0] as? StrV {
            if let s2 = vals[1] as? StrV {
                return BoolV(b: (s1.str == s2.str))
            }
        }
        return BoolV(b: false)
    }
    throw ProgramError.wrongArity
}

let topEnv = Env(list: [EnvStruct(id: "true", val: BoolV(b: true)),
                        EnvStruct(id: "false", val: BoolV(b: false)),
                        EnvStruct(id: "+", val: PrimV(fn: plus)),
                        EnvStruct(id: "-", val: PrimV(fn: minus)),
                        EnvStruct(id: "*", val: PrimV(fn: mult)),
                        EnvStruct(id: "/", val: PrimV(fn: div)),
                        EnvStruct(id: "<=", val: PrimV(fn: leq)),
                        EnvStruct(id: "equal?", val: PrimV(fn: eq))])


func envLookup(env: Env, s: String) throws -> Value {
    for bind in env.list {
        if bind.id == s {
            return bind.val
        }
    }
    throw ProgramError.notInEnv
}

func interpArgs(args: [ExprC], env: Env) -> [Value] {
    var arr = [Value]()
    for a in args {
        arr.append(try! interp(e: a, env: env))
    }
    return arr
}

func interp(e: ExprC, env: Env) throws -> Value {
    switch e {
    case is NumC:
        let x = e as! NumC
        return NumV(num: x.num)
    case is IdC:
        let x = e as! IdC
        return try! envLookup(env: env, s: x.id)
    case is StrC:
        let x = e as! StrC
        return StrV(str: x.str)
    case is AppC:
        let x = e as! AppC
        let y = try interp(e:x.fn, env: env)
        switch y {
        case is PrimV:
            let z = y as! PrimV
            let a = interpArgs(args: x.args, env: env)
            return try! z.fn(a)
        default:
            throw ProgramError.wrongAppC
        }
    default:
        throw ProgramError.wrongExprC
    }
}

// Tests

func testInterpNumC() {
    let num = (try! (interp(e: NumC(num: 1), env: topEnv))) as! NumV
    if num.num != 1 {
        print("Failed NumC interp")
    }
}

func testInterpStrC() {
    let str = (try! (interp(e: StrC(str: "hello"), env: topEnv))) as! StrV
    if str.str != "hello" {
        print("Failed StrC interp")
    }
}

func testInterpPlus() {
    let num = (try! (interp(e: AppC(fn: IdC(id: "+"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! NumV
    if num.num != 3 {
        print("Failed Plus interp")
    }
}

func testInterpMinus() {
    let num = (try! (interp(e: AppC(fn: IdC(id: "-"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! NumV
    if num.num != -1 {
        print("Failed Minus interp")
    }
}


//num = (try! (interp(e: AppC(fn: IdC(id: "*"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! NumV
//print(num.num)
//num = (try! (interp(e: AppC(fn: IdC(id: "/"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! NumV
//print(num.num)
//var bool = (try! (interp(e: AppC(fn: IdC(id: "<="), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! BoolV
//print(bool.b)
//bool = (try! (interp(e: AppC(fn: IdC(id: "equal?"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! BoolV
//print(bool.b)

testInterpNumC()
testInterpStrC()
testInterpPlus()
testInterpMinus()
