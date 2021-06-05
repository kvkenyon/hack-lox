namespace Lox;

class ParseError extends \Exception { /*...*/ }

class Parser {
    private Vector<Token> $tokens;
    private int $current;

    public function __construct(Vector<Token> $tokens) {
        $this->tokens = $tokens;
        $this->current = 0;
    }

    public function parse(): Vector<Stmt> {
        $stmts = new Vector<Stmt>(NULL);
        while (!$this->isAtEnd()) {
            try {
                $stmts->add($this->declaration());
            } catch(ParseError $error) {}
        }
        return $stmts;
    }

    private function declaration(): Stmt {
        try  {
            if ($this->match(TokenType::VAR)) {
                return $this->varDecl();
            }
            return $this->statement();

        } catch(ParseError $error) {
            $this->synchronize();
            throw $error;
        }
   }

    private function varDecl(): Stmt {
        $name = $this->consume(TokenType::IDENTIFIER, 'Expected variable name.');

        $init = NULL;
        if ($this->match(TokenType::EQUAL)) {
            $init = $this->comma();
        }

        $this->consume(TokenType::SEMICOLON, 'Expected ; after variable declaration.');
        return new VarDecl($name, $init);
    }

    private function statement(): Stmt {
        if ($this->match(TokenType::PRINT)) {
            return $this->printStatement();
        }
        return $this->expressionStatement();
    }

    private function printStatement(): Stmt {
        $expr = $this->comma();
        $this->consume(TokenType::SEMICOLON, '; expected after statement.');
        return new Show($expr);
    }

    private function expressionStatement(): Stmt {
        $expr = $this->comma();
        $this->consume(TokenType::SEMICOLON, '; expected after statement.');
        return new Expression($expr);
    }

    private function comma(): Expr {
        $expr = $this->ternary();

        while ($this->match(TokenType::COMMA)) {
            $op = $this->previous();
            $right = $this->ternary();
            $expr = new Binary($expr, $op, $right);
        }

        return $expr;
    }

    private function ternary(): Expr {
        $expr = $this->expression();

        if ($this->match(TokenType::QUESTION)) {
            $b = $this->ternary();
            $this->consume(TokenType::COLON, "Expect ':' after ? ternary expression.");
            $c = $this->ternary();
            return new Ternary($expr, $b, $c);
        }

        return $expr;
    }
    private function expression(): Expr {
        return $this->assignment();
    }

    private function assignment(): Expr {
        $expr = $this->equality();

        if ($this->match(TokenType::EQUAL)) {
            $equal = $this->previous();
            $value = $this->assignment();
            if ($expr is Variable) {
                return new Assign($expr->name, $value);
            }

            $this->error($equal, 'Invalid assignment target.');
        }

        return $expr;
    }

    private function equality(): Expr {
        $expr = $this->comparison();

        while ($this->match(TokenType::BANG_EQUAL,
                TokenType::EQUAL_EQUAL)) {
            $op = $this->previous();
            $right = $this->comparison();
            $expr = new Binary($expr, $op, $right);
        }

        return $expr;
    }

    private function comparison(): Expr {
        $expr = $this->term();

        while ($this->match(TokenType::GREATER,
                TokenType::GREATER_EQUAL, TokenType::LESS,
                TokenType::LESS_EQUAL)) {
            $op = $this->previous();
            $right = $this->term();
            $expr = new Binary($expr, $op, $right);
        }

        return $expr;
    }

    private function term(): Expr {
        $expr = $this->factor();

        while ($this->match(TokenType::PLUS, TokenType::MINUS)) {
            $op = $this->previous();
            $right = $this->factor();
            $expr = new Binary($expr, $op, $right);
        }

        return $expr;
    }

    private function factor(): Expr {
       $expr = $this->unary();

       while ($this->match(TokenType::STAR, TokenType::SLASH)) {
           $op = $this->previous();
           $right = $this->unary();
           $expr = new Binary($expr, $op, $right);
       }

       return $expr;
    }

    private function unary(): Expr {
        if ($this->match(TokenType::BANG, TokenType::MINUS)) {
            return new Unary($this->previous(), $this->unary());
        }
        return $this->primary();
    }

    private function primary(): Expr {
        if ($this->match(TokenType::TRUE)) {
            return new Literal(new Object(true));
        }
        if ($this->match(TokenType::FALSE)) {
            return new Literal(new Object(false));
        }

        if ($this->match(TokenType::NIL)) {
            return new Literal(new Object(NULL));
        }

        if ($this->match(TokenType::IDENTIFIER)) {
            $token = $this->previous();
            return new Variable($token);
        }

        if ($this->match(TokenType::NUMBER) || $this->match(TokenType::STRING)) {
            $token = $this->previous();
            if ($token->literal !== NULL) {
                return new Literal($token->literal);
            } else {
                return new Literal(new Object($token->lexeme));
            }
        } else if ($this->match(TokenType::LEFT_PAREN)) {
            $expr = $this->expression();
            $this->consume(TokenType::RIGHT_PAREN, "Expect ')' after expression.");
            return new Grouping($expr);
        }

        throw $this->error($this->peek(), 'Expect expression.');
    }

    private function consume(TokenType $type, string $msg): Token {
        if (!$this->isAtEnd() && $this->check($type)) {
            return $this->advance();
        }
        throw $this->error($this->peek(), $msg);
    }

    private function error(Token $token, string $msg): ParseError {
        Lox::errorParse($token, $msg);
        return new ParseError();
    }

    private function synchronize(): void {
        $this->advance();

        while (!$this->isAtEnd()) {
            if ($this->previous()->type === TokenType::SEMICOLON) { return; }
            switch($this->peek()->type) {
                case TokenType::CLAZZ:
                case TokenType::FUN:
                case TokenType::VAR:
                case TokenType::FOR:
                case TokenType::IF:
                case TokenType::WHILE:
                case TokenType::PRINT:
                case TokenType::RETURN:
                    return;
                default:
            }
            $this->advance();
        }
    }

    private function match(TokenType ... $types): bool {
        foreach ($types as $type) {
            if ($this->check($type)) {
                $this->advance();
                return true;
            }
        }
        return false;
    }

    private function check(TokenType $type): bool {
        if ($this->isAtEnd()) { return false; }
        return $this->peek()->type === $type;
    }

    private function advance(): Token {
        if (!$this->isAtEnd()) {
            $this->current++;
        }
        return $this->previous();
    }

    private function peek(): Token {
        return $this->tokens[$this->current];
    }

    private function previous(): Token {
        return $this->tokens[$this->current - 1];
    }

    private function isAtEnd(): bool {
        return $this->peek()->type === TokenType::EOF;
    }
}
