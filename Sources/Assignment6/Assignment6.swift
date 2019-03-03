class ExprC {}

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
