namespace Lox;

abstract class Expr {
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
}

class Grouping extends Expr {
    private Expr $expression;
    public function __construct(Expr $expression) {
        $this->expression = $expression;
    }
}

class Literal extends Expr {
    private Object $value;
    public function __construct(Object $value) {
        $this->value = $value;
    }
}

class Unary extends Expr {
    private Token $operator;
    private Expr $right;
    public function __construct(Token $operator, Expr $right) {
        $this->operator = $operator;
        $this->right = $right;
    }
}
