namespace Lox;

class Resolver implements Visitor<void> {
    private Vector<Map<string, bool>> $scopes;

    public function __construct(private Interpreter $interpreter) {
        $this->scopes = new Vector<Map<string, bool>>(NULL);
    }

    public function visitTernaryExpr(Ternary $expr): void {}

    public function visitBinaryExpr(Binary $expr): void {}

    public function visitCallExpr(Call $expr): void {}

    public function visitGroupingExpr(Grouping $expr): void {}

    public function visitLiteralExpr(Literal $expr): void {}

    public function visitLambdaExpr(Lambda $expr): void {}

    public function visitUnaryExpr(Unary $expr): void {}

    public function visitVariableExpr(Variable $expr): void {
        $scope = $this->scopes->lastValue();
        if ($scope !== NULL) {
            if ($scope->get($expr->name->lexeme()) == false) {
                Lox::error($expr->name->line, "Can't read local variable in its own initializer");
            }
        }
    }

    public function visitAssignExpr(Assign $expr): void {}

    public function visitExpressionStmt(Expression $stmt): void {}

    public function visitShowStmt(Show $stmt): void {}

    public function visitVarDeclStmt(VarDecl $stmt): void {
        $this->declare($stmt->name);
        if ($stmt->initializer !== NULL) {
            $this->resolveExpression($stmt->initializer);
        }
        $this->define($stmt->name);
    }

    public function visitBlockStmt(Block $stmt): void {
        $this->beginScope();
        $this->resolveStatements($stmt->statements);
        $this->endScope();
    }

    public function visitIfElseStmt(IfElse $stmt): void {}

    public function visitWhileLoopStmt(WhileLoop $stmt): void {}
    
    public function visitFuncStmt(Func $stmt): void {}

    public function visitRetStmt(Ret $stmt): void {}

    /* -------- *
     * Helpers  * 
     * -------- */
    
    private function declare(Token $name): void {
        $scope = $this->scopes->lastValue();
        if ($scope !== NULL) {
            $scope->set($name->lexeme(), false);
        }
    }

    private function define(Token $name):void {
        $scope = $this->scopes->lastValue();
        if ($scope !== NULL) {
            $scope->set($name->lexeme(), true);
        }
    }
    
    private function resolveStatements(Vector<Stmt> $statements): void {
        foreach ($statements as $statement) {
            $this->resolveStatement($statement);
        }
    }

    private function resolveStatement(Stmt $statement): void {
        $statement->accept($this);
    }

    private function resolveExpression(Expr $expr): void {
        $expr->accept($this);
    }

    private function beginScope(): void {
        $this->scopes->add(new Map<string, bool>(NULL));
    }

    private function endScope(): void {
        $this->scopes->pop();
    }

    
}