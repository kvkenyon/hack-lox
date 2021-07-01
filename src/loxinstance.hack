namespace Lox;
use namespace HH\Lib\C;

class LoxInstance {
    public function __construct(private LoxClass $klass,
     private dict<string, mixed> $fields = dict<string, mixed>[]) {}

    public function get(Token $name): mixed {
        if (C\contains($this->fields, $name)) {
            return $this->fields[$name->lexeme()];
        }

        throw new RuntimeError($name,
         "Undefined property '" . $name->lexeme() . "'.");
    }

    public function __toString(): string {
        return $this->klass->name . ' instance';
    }
}
