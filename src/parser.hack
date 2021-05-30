namespace Lox;

class ParseError extends \Exception { /*...*/ }

class Parser {
    private Vector<Token> $tokens;
    private int $current;

    public function __construct(Vector<Token> $tokens) {
        $this->tokens = $tokens;
        $this->current = 0;
    }

    public function parse(): ?Expr {
        try {
            return $this->comma();
        } catch(ParseError $error) {
            return NULL;
        }
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
        return $this->equality();
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

        if ($this->match(TokenType::NUMBER)) {
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
