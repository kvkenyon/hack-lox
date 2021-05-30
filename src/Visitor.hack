namespace Lox;
interface Visitor<T> {
    public function visitTernaryExpr(Ternary $expr): T;
    public function visitBinaryExpr(Binary $expr): T;
    public function visitGroupingExpr(Grouping $expr): T;
    public function visitLiteralExpr(Literal $expr): T;
    public function visitUnaryExpr(Unary $expr): T;
    public function visitExpressionStmt(Expression $stmt): T;
    public function visitShowStmt(Show $stmt): T;
}
