namespace Lox;
interface Visitor<T> {
    public function visitTernaryExpr(Ternary $expr): T;
    public function visitBinaryExpr(Binary $expr): T;
    public function visitGroupingExpr(Grouping $expr): T;
    public function visitLiteralExpr(Literal $expr): T;
    public function visitUnaryExpr(Unary $expr): T;
    public function visitVariableExpr(Variable $expr): T;
    public function visitAssignExpr(Assign $expr): T;
    public function visitExpressionStmt(Expression $stmt): T;
    public function visitShowStmt(Show $stmt): T;
    public function visitVarDeclStmt(VarDecl $stmt): T;
    public function visitBlockStmt(Block $stmt): T;
    public function visitIfElseStmt(IfElse $stmt): T;
    public function visitWhileLoopStmt(WhileLoop $stmt): T;
}
