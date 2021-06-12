namespace Lox;

class Scope {
    private Map<string, bool> $scope;
    
    public function __construct() {
        $this->scope = new Map<string, bool>(NULL);
    }
}

class Resolver implements Visitor<void> {
    private Vector<Scope> $scopes;

    public function __construct(private Interpreter $interpreter) {
        $this->scopes = new Vector<Scope>(NULL);
    }

    public function visitTernaryExpr(Ternary $expr): void {}

    public function visitBinaryExpr(Binary $expr): void {}

    public function visitCallExpr(Call $expr): void {}

    public function visitGroupingExpr(Grouping $expr): void {}

    public function visitLiteralExpr(Literal $expr): void {}

    public function visitLambdaExpr(Lambda $expr): void {}

    public function visitUnaryExpr(Unary $expr): void {}

    public function visitVariableExpr(Variable $expr): void {}

    public function visitAssignExpr(Assign $expr): void {}

    public function visitExpressionStmt(Expression $stmt): void {}

    public function visitShowStmt(Show $stmt): void {}

    public function visitVarDeclStmt(VarDecl $stmt): void {
        
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

    }
    
    private function resolveStatements(Vector<Stmt> $statements): void {
        foreach ($statements as $statement) {
            $statement->accept($this);
        }
    }

    private function resolveStatement(Stmt $statement): void {
        $statement->accept($this);
    }

    private function resolveExpression(Expr $expr): void {
        $expr->accept($this);
    }

    private function beginScope(): void {
        $this->scopes->add(new Scope());
    }

    private function endScope(): void {
        $this->scopes->pop();
    }

    
}