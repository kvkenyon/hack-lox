namespace Lox;
use namespace HH\Lib\{Str};


class Scanner {
    private string $source;
    private int $start = 0;
    private int $current = 0;
    private int $line = 1;

    private Vector<Token> $tokens;

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
        default:
            Lox::error($this->line, 'Unexpected character.\n');
            break;
        }
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

    private function isAtEnd(): bool {
        return $this->current >= Str\length($this->source);
    }

    private function lexemeLength(): int {
        return $this->current - $this->start + 1;
    }
}