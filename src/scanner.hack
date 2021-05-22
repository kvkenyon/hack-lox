namespace Lox;
use namespace HH\Lib\{C, Str};

class Scanner {
    private string $source;
    private int $start = 0;
    private int $current = 0;
    private int $line = 1;

    private Vector<Token> $tokens;

    private static dict<string, TokenType> $keywords = dict[
        'and' => TokenType::AND,
        'class' => TokenType::CLAZZ,
        'else' => TokenType::ELSE,
        'false' => TokenType::FALSE,
        'for' => TokenType::FOR,
        'fun' => TokenType::FUN,
        'if' => TokenType::IF,
        'nil' => TokenType::NIL,
        'or' => TokenType::OR,
        'print' => TokenType::PRINT,
        'return' => TokenType::RETURN,
        'super' => TokenType::SUPER,
        'this' => TokenType::THIS,
        'true' => TokenType::TRUE,
        'var' => TokenType::VAR,
        'while' => TokenType::WHILE
    ];

    public function __construct(string $source) {
        $this->source = $source;
        $this->tokens = new Vector(NULL);
    }

    public function scanTokens(): Vector<Token> {
        while (!$this->isAtEnd()) {
            $this->start = $this->current;
            $this->scanToken();
        }
        $this->tokens->add(new Token('', TokenType::EOF, $this->line, NULL));
        return $this->tokens;
    }

    private function scanToken(): void {
        $c = $this->advance();
        switch ($c) {
        case '(':
            $this->addToken(TokenType::LEFT_PAREN);
            break;
        case ')':
            $this->addToken(TokenType::RIGHT_PAREN);
            break;
        case '{':
            $this->addToken(TokenType::LEFT_BRACE);
            break;
        case '}':
            $this->addToken(TokenType::RIGHT_BRACE);
            break;
        case ',':
            $this->addToken(TokenType::COMMA);
            break;
        case '.':
            $this->addToken(TokenType::DOT);
            break;
        case '-':
            $this->addToken(TokenType::MINUS);
            break;
        case '+':
            $this->addToken(TokenType::PLUS);
            break;
        case ';':
            $this->addToken(TokenType::SEMICOLON);
            break;
        case '*':
            $this->addToken(TokenType::STAR);
            break;
        case '!':
            $this->addToken($this->match('=') ? TokenType::BANG_EQUAL : TokenType::BANG);
            break;
        case '=':
            $this->addToken($this->match('=') ? TokenType::EQUAL_EQUAL: TokenType::EQUAL);
            break;
        case '<':
            $this->addToken($this->match('=') ? TokenType::LESS_EQUAL: TokenType::LESS);
            break;
        case '>':
            $this->addToken($this->match('=') ? TokenType::GREATER_EQUAL: TokenType::GREATER);
            break;
        case '/':
            if ($this->match('/')) {
                while ($this->peek() !== '\n' && !$this->isAtEnd()) {
                    $this->advance();
                }
            } else if($this->match('*')) {
                $this->blockComment();
            } else {
                $this->addToken(TokenType::SLASH);
            }
            break;
        case ' ':
        case '\r':
        case '\t':
            break;
        case '\n':
            $this->line++;
            break;
        case '"':
            $this->string();
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            $this->number();
            break;
        default:
            if ($this->isAlpha($c)) {
                $this->identifier();
            } else {
                Lox::error($this->line, 'Unexpected character in switch.');
            }
            break;
        }
    }

    private function string(): void {
        while ($this->peek() !== '"' && !$this->isAtEnd()) {
            if ($this->peek() === '\n') {
                $this->line++;
            }
            $this->advance();
        }

        if ($this->isAtEnd()) {
            Lox::error($this->line, 'Unterminated string.');
            return;
        }

        $this->advance();

        $value = Str\slice($this->source, $this->start + 1, $this->lexemeLength() - 1);
        $this->addTokenLiteral(TokenType::STRING, new Object($value));
    }

    private function number(): void {
        while ($this->isDigit($this->peek())) { $this->advance(); }

        if ($this->peek() === '.' && $this->isDigit($this->peekNext())) {
            $this->advance();
        }

        while ($this->isDigit($this->peek())) { $this->advance(); }

        $value = (float) Str\slice($this->source, $this->start, $this->lexemeLength());
        $this->addTokenLiteral(TokenType::NUMBER, new Object($value));
    }

    private function identifier(): void {
        while ($this->isAlphaNum($this->peek())) {
            $this->advance();
        }

        $value = (string) Str\slice($this->source, $this->start, $this->lexemeLength());
        $identifier = TokenType::IDENTIFIER;
        if (C\contains(Scanner::$keywords, $value)) {
            $identifier = Scanner::$keywords[$value];
        }
        $this->addTokenLiteral($identifier, new Object($value));
    }

    private function blockComment(): void {
        while (true) {
            if ($this->peek() === '*' && $this->peekNext() === '/') {
                /* Consume terminating */
                $this->advance();
                $this->advance();
                break;
            } else if ($this->isAtEnd()) {
                Lox::error($this->line, 'Incomplete block comment.');
                break;
            }

            if ($this->peek() === '\n') {
                $this->line++;
            }

            $this->advance();
        }
    }

    private function peek(): string {
        if ($this->isAtEnd()) {
            return '\0';
        }
        return $this->source[$this->current];
    }

    private function peekNext(): string {
        $len = Str\length($this->source);
        if ($this->current + 1 >= $len) {
            return '\0';
        }
        return $this->source[$this->current + 1];
    }

    private function advance(): string {
       $c = $this->source[$this->current];
       $this->current++;
       return $c;
    }

    private function match(string $expected): bool {
        if ($this->isAtEnd()) { return false; }
        if ($this->source[$this->current] !== $expected) {
           return false;
        }
        $this->current++;
        return true;
    }

    private function addToken(TokenType $type): void {
        $this->addTokenLiteral($type, NULL);
    }

    private function addTokenLiteral(TokenType $type, ?Object $literal): void {
        $lexeme = Str\slice($this->source, $this->start, $this->lexemeLength());
        $this->tokens->add(new Token($lexeme, $type, $this->line, $literal));
    }

    private function lexemeLength(): int {
        return $this->current - $this->start;
    }

    private function isAtEnd(): bool {
        return $this->current >= Str\length($this->source);
    }

    private function isDigit(string $c): bool {
        if ($c === '0') {
            return true;
        }
        return Str\to_int($c) !== NULL;
    }

    private function isAlpha(string $c): bool {
        return ($c >= 'a' && $c <= 'z') ||
                ($c >= 'A' && $c <= 'Z') ||
                $c === '_';
    }

    private function isAlphaNum(string $c): bool {
        return $this->isDigit($c) || $this->isAlpha($c);
    }
}
