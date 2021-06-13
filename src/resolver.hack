namespace Lox;

use namespace HH\Lib\C;

class Resolver implements Visitor<void> {
    private Vector<dict<string, bool>> $scopes;

    public function __construct(private Interpreter $interpreter) {
        $this->scopes = new Vector<dict<string, bool>>(NULL);
    }

    public function visitTernaryExpr(Ternary $expr): void {
        $this->resolveExpression($expr->a);
        $this->resolveExpression($expr->b);
        $this->resolveExpression($expr->c);
    }

    public function visitBinaryExpr(Binary $expr): void {
        $this->resolveExpression($expr->left);
        $this->resolveExpression($expr->right);
    }

    public function visitCallExpr(Call $expr): void {
        $this->resolveExpression($expr->calle);
        foreach ($expr->arguments as $arg) {
            $this->resolveExpression($arg);
        }
    }

    public function visitGroupingExpr(Grouping $expr): void {
        $this->resolveExpression($expr->expression);
    }

    public function visitLiteralExpr(Literal $expr): void {}

    public function visitLambdaExpr(Lambda $expr): void {
        $this->beginScope();
        foreach ($expr->params as $param) {
            $this->declare($param);
            $this->define($param);
        }
        $this->resolveStatements($expr->body);
        $this->endScope();
    }

    public function visitUnaryExpr(Unary $expr): void {
        $this->resolveExpression($expr->right);
    }

    public function visitVariableExpr(Variable $expr): void {
        $scope = $this->scopes->lastValue();
        if ($scope !== NULL) {
            if (C\contains_key($scope, $expr->name->lexeme()) && !$scope[$expr->name->lexeme()]) {
                Lox::error($expr->name->line, "Can't read local variable in its own initializer");
            }
        }
        $this->resolveLocal($expr, $expr->name);
    }

    public function visitAssignExpr(Assign $expr): void {
        $this->resolveExpression($expr->value);
        $this->resolveLocal($expr, $expr->name);
    }

    public function visitExpressionStmt(Expression $stmt): void {
        $this->resolveExpression($stmt->expression);
    }

    public function visitShowStmt(Show $stmt): void {
        $this->resolveExpression($stmt->expression);
    }

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

    public function visitIfElseStmt(IfElse $stmt): void {
        $this->resolveExpression($stmt->condition);
        $this->resolveStatement($stmt->thenBranch);
        if ($stmt->elseBranch !== NULL) {
            $this->resolveStatement($stmt->elseBranch);
        } 
    }

    public function visitWhileLoopStmt(WhileLoop $stmt): void {
        $this->resolveExpression($stmt->condition);
        $this->resolveStatement($stmt->body);
    }
    
    public function visitFuncStmt(Func $stmt): void {
        $this->declare($stmt->name);
        $this->define($stmt->name);
        $this->resolveFunction($stmt);
    }

    public function visitRetStmt(Ret $stmt): void {
        if ($stmt->value !== NULL) {
            $this->resolveExpression($stmt->value);
        }
    }

    /* -------- *
     * Helpers  * 
     * -------- */
    
    private function declare(Token $name): void {
        $scope = $this->scopes->lastValue();
        if ($scope !== NULL) {
            $this->scopes[$this->scopes->count()-1][$name->lexeme()] = false;
        }
    }

    private function define(Token $name):void {
        $scope = $this->scopes->lastValue();
        if ($scope !== NULL) {
            $this->scopes[$this->scopes->count()-1][$name->lexeme()] = true;
        }
    }
    
    public function resolveStatements(Vector<Stmt> $statements): void {
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

    private function resolveLocal(Expr $expr, Token $name): void {
        if ($this->scopes->isEmpty()) { return; }
        $numScopes = $this->scopes->count();
        for ($i = $numScopes - 1; $i >= 0; --$i) {
            if (C\contains_key($this->scopes->at($i), $name->lexeme())) {
                $scopeDepth = $numScopes - 1 - $i;
                $this->interpreter->resolve($expr, $scopeDepth); 
                return;
            }
        }
    }

    private function resolveFunction(Func $stmt): void {
        $this->beginScope();
        foreach ($stmt->params as $param) {
            $this->declare($param);
            $this->define($param);
        }
        $this->resolveStatements($stmt->body);
        $this->endScope();
    }

    private function beginScope(): void {
        $this->scopes->add(dict<string, bool>[]);
    }

    private function endScope(): void {
        $this->scopes->pop();
    }
}
