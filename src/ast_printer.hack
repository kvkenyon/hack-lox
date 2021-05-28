namespace Lox;

class AstPrinter implements Visitor<string> {
    public function print(Expr $expr): string {
       return $expr->accept($this);
    }

    public function visitBinaryExpr(Binary $expr): string {
        return $this->parenthesize($expr->operator->lexeme, $expr->left, $expr->right);
    }

    public function visitGroupingExpr(Grouping $expr): string {
        return $this->parenthesize('group', $expr->expression);
    }

    public function visitLiteralExpr(Literal $expr): string {
        if ($expr->value === NULL) { return 'nil'; }
        return (string)$expr->value->value();
    }

    public function visitUnaryExpr(Unary $expr): string {
        return $this->parenthesize($expr->operator->lexeme(), $expr->right);
    }

    public function visitTernaryExpr(Ternary $expr): string {
        return $this->parenthesize('ternary', $expr->a, $expr->b, $expr->c);
    }

    private function parenthesize(string $name, Expr ... $exprs):string {
        $result = '(' . $name . ' ';

        foreach ($exprs as $expr) {
            $result .= $expr->accept($this) . ' ';
        }

        $result .= ')';

        return $result;
    }
}
