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

class NumC : ExprC, CustomStringConvertible {
    let num : Float
    
    init (num : Float) {
        self.num = num
    }
    
    public var description : String { return "NumC: \(num)"}
    
}

class StrC : ExprC, CustomStringConvertible {
    let str : String
    
    init (str : String) {
        self.str = str
    }
    
    public var description : String { return "StrC: \(str)" }
}


class IdC : ExprC, CustomStringConvertible {
    let id : String
    
    init (id : String) {
        self.id = id
    }
    
    public var description : String { return "IdC: \(id)" }
}

class AppC : ExprC, CustomStringConvertible {
    let fn : ExprC
    let args : [ExprC]
    
    init (fn : ExprC, args : [ExprC]) {
        self.fn = fn
        self.args = args
    }
    
    public var description : String { return "AppC: \(fn) \(args)" }
}

class IfC : ExprC, CustomStringConvertible {
    let ifStmnt : ExprC
    let thenStmnt : ExprC
    let elseStmnt : ExprC
    
    init (ifStmnt : ExprC, thenStmnt : ExprC, elseStmnt : ExprC) {
        self.ifStmnt = ifStmnt
        self.thenStmnt = thenStmnt
        self.elseStmnt = elseStmnt
    }
    
    public var description : String { return "IfC: \(ifStmnt) \(thenStmnt) \(elseStmnt)" }
}

class LamC : ExprC, CustomStringConvertible {
    let param : [ExprC]
    let body : ExprC
    
    init (param : [ExprC], body : ExprC) {
        self.param = param
        self.body = body
    }
    
    public var description : String { return "LamC: \(param) \(body)"}
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

class Expr {}

class SingleExpr : Expr, CustomStringConvertible {
    let e : String
    init (e : String) {
        self.e = e
    }
    public var description : String { return e}
}

class MultiExpr : Expr, CustomStringConvertible {
    var e : [Expr]
    init(e : [Expr]){
        self.e = e
    }
    public var description : String { return "\(e)" }
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
    case is IfC:
        let x = e as! IfC
        let test = try! interp(e: x.ifStmnt, env: env)
        switch test {
            case is BoolV:
                let test2 = test as! BoolV
                if (test2.b) {
                    return try! interp(e: x.thenStmnt, env: env)
                } else {
                    return try! interp(e: x.elseStmnt, env: env)
                }
            default:
                throw ProgramError.wrongExprC
        }
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

func setupParse (program : String) -> Expr {
    var index = 0
    var start = 0
    var count = 0
    var e : Expr
    if (program[String.Index(encodedOffset: index)] == "{" &&  program[String.Index(encodedOffset: program.count-1)] == "}") {
        while (program[String.Index(encodedOffset: index)] != "}" || count != 1) {
            if (program[String.Index(encodedOffset: index)] == "{") {
                count = count + 1
            }
            if (program[String.Index(encodedOffset: index)] == "}") {
                count = count - 1
            }
            index = index + 1
        }
        e = setupParse(program: String(program[String.Index(encodedOffset: 1)..<String.Index(encodedOffset: index)]))
        if let e2 = e as? SingleExpr {
            e = MultiExpr(e: [])
            (e as! MultiExpr).e.append(e2)
        }
    } else {
        e = MultiExpr(e: [])
        while (index < program.count) {
            while (index < program.count && (program[String.Index(encodedOffset: index)] != " ")) {
                if (program[String.Index(encodedOffset: index)] == "{") {
                    while (index < program.count && program[String.Index(encodedOffset: index)] != "}" || count != 1) {
                            if (program[String.Index(encodedOffset: index)] == "{") {
                                count = count + 1
                             }
                            if (program[String.Index(encodedOffset: index)] == "}") {
                                count = count - 1
                            }
                            index = index + 1
                    }
                }
                index = index + 1
            } 
            if (start == 0 && index == program.count) {
                return SingleExpr(e: program)
            }
            (e as! MultiExpr).e.append(setupParse(program: String(program[String.Index(encodedOffset: start)..<String.Index(encodedOffset: index)])))
            index = index + 1
            start = index
        }
    }
    return e
}

func parse (e : Expr) -> ExprC {
    if let se = e as? SingleExpr {
        let n = Float(se.e)
        if n != nil {
            return NumC(num: n!)
        }
        if se.e[String.Index(encodedOffset: 0)] == "\"" {
            return StrC(str: se.e);
        }
        return IdC(id: se.e)
    }
    if let me = e as? MultiExpr {
        if let e1 = me.e[0] as? SingleExpr {
            if e1.e == "if" && me.e.count == 4 {
                return IfC(ifStmnt: parse(e: me.e[1]), thenStmnt: parse(e: me.e[2]), elseStmnt: parse(e: me.e[3]))
            }
            let e2 = me.e[1] as? MultiExpr
            if (e1.e == "lam" && e2 != nil && e1.e.count == 3) {
                print("hi")
                var e3 : [ExprC]
                e3 = []
                for e4 in e2!.e {
                    e3.append(parse(e: e4))
                }
                return LamC(param: e3, body: parse(e: me.e[2]))
            }
        }
        var e6 : [ExprC]
            e6 = []
            for i in 1..<me.e.count {
                e6.append(parse(e: me.e[i]))
            }
            return AppC(fn: parse(e: me.e[0]), args: e6)
    }
    return ExprC()
}

//print(setupParse(program: "ab ab"))
print(setupParse(program: "{4 {1 2}}"))
print(setupParse(program: "{4 {2} 3}"))
print(parse(e: setupParse(program: "1")))
print(parse(e: setupParse(program: "\"Hi\"")))
print(parse(e: setupParse(program: "+")))
print(parse(e: setupParse(program: "{if 1 2 3}")))
print(parse(e: setupParse(program: "{lam {a b} 3}")))
print(parse(e: setupParse(program: "{a 1 2 3}")))
print(parse(e: setupParse(program: "{{lam {a b} 3} 1 2}")))

func validChar (c : Character) -> Bool {
    if c == "{" || c == "}" || c == " " {
        return false
    }
    return true
}

// Tests
func testPrimPlus() {
    let vals = [NumV(num: 1), NumV(num: 5)]
    let res = (try! (plus(vals: vals))) as! NumV
    if res.num != 6 {
        print("Failed prim plus:")
        print("expected ", 6)
        print("actual ", res.num)
    }
}

func testPrimMinus() {
    let vals = [NumV(num: 1), NumV(num: 5)]
    let res = (try! (minus(vals: vals))) as! NumV
    if res.num != -4 {
        print("Failed prim minus:")
        print("expected ", 4)
        print("actual ", res.num)
    }
}

func testPrimMult() {
    let vals = [NumV(num: 2), NumV(num: 5)]
    let res = (try! (mult(vals: vals))) as! NumV
    if res.num != 10 {
        print("Failed prim mult:")
        print("expected ", 10)
        print("actual ", res.num)
    }
}

func testPrimDiv() {
    let vals = [NumV(num: 10), NumV(num: 5)]
    let res = (try! (div(vals: vals))) as! NumV
    if res.num != 2 {
        print("Failed prim div:")
        print("expected ", 2)
        print("actual ", res.num)
    }
}

func testPrimLeq() {
    let vals = [NumV(num: 1), NumV(num: 5)]
    let res = (try! (leq(vals: vals))) as! BoolV
    if !res.b {
        print("Failed prim leq:")
    }
}

func testPrimEq() {
    let vals = [NumV(num: 1), NumV(num: 5)]
    let res = (try! (eq(vals: vals))) as! BoolV
    if res.b {
        print("Failed prim eq:")
    }
}

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

func testInterpMult() {
   let num = (try! (interp(e: AppC(fn: IdC(id: "*"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! NumV
    if num.num != 2 {
        print("Failed Mult interp")
    }
}

func testInterpDiv() {
    let num = (try! (interp(e: AppC(fn: IdC(id: "/"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! NumV
    if num.num != 0.5 {
        print("Failed Div Interp")
    }
}

func testInterpLeq() {
    let bool = (try! (interp(e: AppC(fn: IdC(id: "<="), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! BoolV
    if !bool.b {
        print("Failed <= Interp")
    }
}

func testInterpEq() {
    let bool = (try! (interp(e: AppC(fn: IdC(id: "equal?"), args: [NumC(num: 1), NumC(num: 2)]), env: topEnv))) as! BoolV
    if bool.b {
        print("Failed equal? Interp")
    }
}

func testInterpIfC() {
    let num = (try! (interp(e: IfC(ifStmnt: IdC(id: "true"), thenStmnt: NumC(num: 1), elseStmnt: NumC(num: 2)), env: topEnv))) as! NumV
    if num.num != 1 {
        print("Failed IfC Interp")
    }
}
func testInitNumC() {
    let n = NumC(num: 1)
    if n.num != 1 {
        print("Failed NumC")
    }   
}

func testInitStrC() {
    let s = StrC(str: "hi")
    if s.str != "hi" {
        print("Failed StrC")
    } 
}
    
func testInitIdC() {
    let id = IdC(id: "hi")
    if id.id != "hi" {
        print("Failed IdC")
    }
}
    
func testInitAppC() {
    let app = AppC(fn: NumC(num: 1), args: [NumC(num: 1)])
    if (app.fn as! NumC).num != 1 {
        print("Failed AppC")
    }
}
    
func testInitIfC() {
    let f = IfC(ifStmnt: NumC(num: 1), thenStmnt: NumC(num: 1), elseStmnt: NumC(num: 2))
    if !(((f.ifStmnt as! NumC).num == 1) && ((f.thenStmnt as! NumC).num == 1)) {
        print("Failed IfC")
    }
}
    
func testInitLamC() {
    let l = LamC(param: [NumC(num: 1)], body: NumC(num: 1))
    if (l.param[0] as! NumC).num != 1 {
        print("Failed LamC")
    }
}

func testInitNumV() {
    let n = NumV(num: 1)
    if n.num != 1 {
        print("Failed NumV")
    }
}
    
func testInitStrV() {
    let s = StrV(str: "hi")
    if s.str != "hi" {
        print("Failed StrV")
    }
}
    
func testInitCloV() {
    let c = CloV(param: [IdC(id: "hi")], body: NumC(num: 1), cloEnv: Env(list: []))
    if !((c.param[0].id == "hi") && ((c.body as! NumC).num == 1)) {
        print("Failed CloV")
    }
}
    
func testInitBoolV() {
    let b = BoolV(b: true)
    if !b.b {
        print("Failed BoolV")
    }
}

testInterpNumC()
testInterpStrC()
testInterpPlus()
testInterpMinus()
testInterpMult()
testInterpDiv()
testInterpLeq()
testInterpEq()
testInterpIfC()
testInitNumC()
testInitStrC()
testInitIdC()
testInitAppC()
testInitIfC()
testInitLamC()
testInitNumV()
testInitStrV()
testInitCloV()
testInitBoolV()
testPrimPlus()
testPrimMinus()
testPrimMult()
testPrimDiv()
testPrimLeq()
testPrimEq()
