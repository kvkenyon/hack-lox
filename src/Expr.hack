namespace Lox;

abstract class Expr {
    abstract public function accept<T>(Visitor<T> $visitor): T;
}

class Binary extends Expr {
    private Expr $left;
    private Token $operator;
    private Expr $right;
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

class Grouping extends Expr {
    private Expr $expression;
    public function __construct(Expr $expression) {
        $this->expression = $expression;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitGroupingExpr($this);
    }
}

class Literal extends Expr {
    private Object $value;
    public function __construct(Object $value) {
        $this->value = $value;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitLiteralExpr($this);
    }
}

class Unary extends Expr {
    private Token $operator;
    private Expr $right;
    public function __construct(Token $operator, Expr $right) {
        $this->operator = $operator;
        $this->right = $right;
    }

    <<__Override>>
    public function accept<T>(Visitor<T> $visitor): T {
        return $visitor->visitUnaryExpr($this);
    }
}

interface Visitor<T> {
    public function visitBinaryExpr(Binary $expr): T;
    public function visitGroupingExpr(Grouping $expr): T;
    public function visitLiteralExpr(Literal $expr): T;
    public function visitUnaryExpr(Unary $expr): T;
}
