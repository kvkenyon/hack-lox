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

class Block extends Stmt {
    public Vector<Stmt> $statements;
    public function __construct(Vector<Stmt> $statements) {
        $this->statements = $statements;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitBlockStmt($this);
    }
}

class IfElse extends Stmt {
    public Expr $condition;
    public Stmt $thenBranch;
    public ?Stmt $elseBranch;
    public function __construct(Expr $condition, Stmt $thenBranch, ?Stmt $elseBranch) {
        $this->condition = $condition;
        $this->thenBranch = $thenBranch;
        $this->elseBranch = $elseBranch;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitIfElseStmt($this);
    }
}

class WhileLoop extends Stmt {
    public Expr $condition;
    public Stmt $body;
    public function __construct(Expr $condition, Stmt $body) {
        $this->condition = $condition;
        $this->body = $body;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitWhileLoopStmt($this);
    }
}

class Func extends Stmt {
    public Token $name;
    public Vector<Token> $params;
    public Vector<Stmt> $body;
    public function __construct(Token $name, Vector<Token> $params, Vector<Stmt> $body) {
        $this->name = $name;
        $this->params = $params;
        $this->body = $body;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitFuncStmt($this);
    }
}

class Ret extends Stmt {
    public Token $keyword;
    public ?Expr $value;
    public function __construct(Token $keyword, ?Expr $value) {
        $this->keyword = $keyword;
        $this->value = $value;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitRetStmt($this);
    }
}
