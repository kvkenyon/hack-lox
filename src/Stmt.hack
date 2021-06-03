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

class VarDecl extends Stmt {
    public Token $name;
    public ?Expr $initializer;
    public function __construct(Token $name, ?Expr $initializer) {
        $this->name = $name;
        $this->initializer = $initializer;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitVarDeclStmt($this);
    }
}
