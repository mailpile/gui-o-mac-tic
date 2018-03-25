precedencegroup BooleanPrecedence {
    associativity: left
}
infix operator ^^ : BooleanPrecedence
func ^^(lhs: Bool, rhs: Bool) -> Bool {
    return lhs != rhs
}
