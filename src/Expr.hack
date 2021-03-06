namespace Lox;

abstract class Expr {
    abstract public function accept<T>(Visitor<T> $visitor): T;
}

class Ternary extends Expr {
    public Expr $a;
    public Expr $b;
    public Expr $c;
    public function __construct(Expr $a, Expr $b, Expr $c) {
        $this->a = $a;
        $this->b = $b;
        $this->c = $c;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitTernaryExpr($this);
    }
}

class Binary extends Expr {
    public Expr $left;
    public Token $operator;
    public Expr $right;
    public function __construct(Expr $left, Token $operator, Expr $right) {
        $this->left = $left;
        $this->operator = $operator;
        $this->right = $right;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitBinaryExpr($this);
    }
}

class Call extends Expr {
    public Expr $calle;
    public Token $paren;
    public Vector<Expr> $arguments;
    public function __construct(Expr $calle, Token $paren, Vector<Expr> $arguments) {
        $this->calle = $calle;
        $this->paren = $paren;
        $this->arguments = $arguments;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitCallExpr($this);
    }
}

class Get extends Expr {
    public Expr $object;
    public Token $name;
    public function __construct(Expr $object, Token $name) {
        $this->object = $object;
        $this->name = $name;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitGetExpr($this);
    }
}

class Grouping extends Expr {
    public Expr $expression;
    public function __construct(Expr $expression) {
        $this->expression = $expression;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitGroupingExpr($this);
    }
}

class Literal extends Expr {
    public Object $value;
    public function __construct(Object $value) {
        $this->value = $value;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitLiteralExpr($this);
    }
}

class Lambda extends Expr {
    public Vector<Token> $params;
    public Vector<Stmt> $body;
    public function __construct(Vector<Token> $params, Vector<Stmt> $body) {
        $this->params = $params;
        $this->body = $body;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitLambdaExpr($this);
    }
}

class Unary extends Expr {
    public Token $operator;
    public Expr $right;
    public function __construct(Token $operator, Expr $right) {
        $this->operator = $operator;
        $this->right = $right;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitUnaryExpr($this);
    }
}

class Variable extends Expr {
    public Token $name;
    public function __construct(Token $name) {
        $this->name = $name;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitVariableExpr($this);
    }
}

class Assign extends Expr {
    public Token $name;
    public Expr $value;
    public function __construct(Token $name, Expr $value) {
        $this->name = $name;
        $this->value = $value;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitAssignExpr($this);
    }
}
