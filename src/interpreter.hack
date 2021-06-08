namespace Lox;

class RuntimeError extends \Exception {
    <<__Override>>
    public function __construct(public Token $token, string $message) {
       parent::__construct($message);
    }
}

class Interpreter implements Visitor<mixed> {
    private Environment $environ;

    public function __construct() {
        $this->environ = new Environment();
    }

    public function interpret(Vector<Stmt> $statements): void {
        try {
            foreach ($statements as $stmt) {
                $this->execute($stmt);
            }
        } catch (RuntimeError $error) {
            Lox::errorRuntime($error);
        }
    }

    public function visitVarDeclStmt(VarDecl $varDecl): void {
        $value = NULL;
        if ($varDecl->initializer !== NULL) {
            $value = $this->evaluate($varDecl->initializer);
        }
        $this->environ->define($varDecl->name->lexeme(), $value);
    }

    public function visitBlockStmt(Block $block): void {
        // TODO: Implement
        $this->executeBlock($block, new Environment(dict[], $this->environ));
    }

    public function visitExpressionStmt(Expression $expression): void {
        $this->evaluate($expression->expression);
    }

    public function visitShowStmt(Show $expression): void {
        $value = $this->evaluate($expression->expression);
        \printf("%s\n", $this->stringify($value));
    }

    public function visitVariableExpr(Variable $expr): mixed {
        return $this->environ->get($expr->name);
    }

    public function visitAssignExpr(Assign $expr): mixed {
        $value = $this->evaluate($expr->value);
        $this->environ->assign($expr->name, $value);
        return $value;
    }

    public function visitBinaryExpr(Binary $binary): mixed {
        $left = $this->evaluate($binary->left);
        $right = $this->evaluate($binary->right);

        switch ($binary->operator->type) {
            case TokenType::MINUS:
                return (float)$left - (float)$right;
            case TokenType::PLUS:
                if (\is_numeric($left) && \is_numeric($right)) {
                    return (float)$left + (float)$right;
                }
                if (\is_string($left) && \is_string($right)) {
                    return (string) $left . (string)$right;
                }
                throw new RuntimeError($binary->operator, 'Operands must be either numbers or strings.');
            case TokenType::SLASH:
                $this->checkNumberOperands($binary->operator, $left, $right);
                if ((float)$right === 0.0) {
                    throw new RuntimeError($binary->operator, 'Division by zero detected.');
                }
                return (float)$left / (float)$right;
            case TokenType::STAR:
                $this->checkNumberOperands($binary->operator, $left, $right);
                return (float)$left * (float)$right;
            case TokenType::GREATER:
                $this->checkNumberOperands($binary->operator, $left, $right);
                return (float)$left > (float)$right;
            case TokenType::GREATER_EQUAL:
                $this->checkNumberOperands($binary->operator, $left, $right);
                return (float)$left >= (float)$right;
            case TokenType::LESS:
                $this->checkNumberOperands($binary->operator, $left, $right);
                return (float)$left < (float)$right;
            case TokenType::LESS_EQUAL:
                $this->checkNumberOperands($binary->operator, $left, $right);
                return (float)$left <= (float)$right;
            case TokenType::BANG_EQUAL:
                return !$this->isEqual($left, $right);
            case TokenType::EQUAL_EQUAL:
                return $this->isEqual($left, $right);
            default:
                throw new RuntimeError($binary->operator, 'Unsupported operation.');
        }
        return NULL;
    }

    public function visitTernaryExpr(Ternary $ternary): mixed {
        $a = $this->evaluate($ternary->a);
        if ($this->isTruthy($a)) {
            return $this->evaluate($ternary->b);
        }
        return $this->evaluate($ternary->c);
    }

    public function visitUnaryExpr(Unary $unary): mixed {
        $right = $this->evaluate($unary->right);

        switch($unary->operator->type) {
            case TokenType::BANG:
                return !$this->isTruthy($right);
            case TokenType::MINUS:
                $this->checkNumberOperand($unary->operator, $right);
                return -(float)$right;
            default:
                throw new RuntimeError($unary->operator, 'Unsupported operation.');
        }

        return NULL;
    }

    public function visitLiteralExpr(Literal $literal): mixed {
        return $literal->value->value();
    }

    public function visitGroupingExpr(Grouping $grouping): mixed {
        return $this->evaluate($grouping->expression);
    }

    private function evaluate(Expr $expr): mixed {
        return $expr->accept($this);
    }

    private function execute(Stmt $stmt): void {
        $stmt->accept($this);
    }

    private function executeBlock(Block $block, Environment $environ): void {
        $previous = $this->environ;
        try {
            $this->environ = $environ;
            foreach ($block->statements as $statement) {
                $this->execute($statement);
            }
        } finally {
            $this->environ = $previous;
        }
    }

    private function isTruthy(mixed $obj): bool {
        if ($obj === NULL) {
            return false;
        }

        if (\is_bool($obj)) {
            return (bool)$obj;
        }

        return true;
    }

    private function isEqual(mixed $left, mixed $right): bool {
        if ($left === null && $right === null) {
            return true;
        }

        return $left === $right;
    }

    private function checkNumberOperand(Token $operator, mixed $operand): void {
        if (\is_numeric($operand)) { return; }
        throw new RuntimeError($operator, 'Operand must be a number.');
    }

    private function checkNumberOperands(Token $operator, mixed $left, mixed $right): void {
        if (\is_numeric($left) && \is_numeric($right)) { return; }
        throw new RuntimeError($operator, 'Operands must be a number');
    }

    private function stringify(mixed $value): string {
        if ($value === NULL) {
            return 'nil';
        }

        if (\is_bool($value)) {
            return $value ? 'true' : 'false';
        }

        return (string) $value;
    }
}
