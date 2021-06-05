namespace Lox;

use namespace HH\Lib\C;

class Environment {
    public function __construct(private dict<string, mixed> $environ = dict[]) {}

    public function define(string $name, mixed $value): void {
        $this->environ[$name] = $value;
    }

    public function get(Token $name): mixed {
        if (C\contains_key($this->environ, $name->lexeme())) {
            return $this->environ[$name->lexeme()];
        }

        throw new RuntimeError($name, 'Undefined variable ' . $name->lexeme() . '.');
    }
}
