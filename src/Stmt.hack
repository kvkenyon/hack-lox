namespace Lox;

abstract class Stmt {
    abstract public function accept<T>(Visitor<T> $visitor): T;
}

class Expression extends Stmt {
    public Expr $expression;
    public function __construct(Expr $expression) {
        $this->expression = $expression;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitExpressionStmt($this);
    }
}

class Show extends Stmt {
    public Expr $expression;
    public function __construct(Expr $expression) {
        $this->expression = $expression;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitShowStmt($this);
    }
}
