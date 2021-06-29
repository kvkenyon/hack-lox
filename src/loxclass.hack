namespace Lox;

class LoxClass implements LoxCallable {
    public function __construct(public string $name) {}
    public function __toString(): string {
        return $this->name;
    }

    public function call(Interpreter $interpreter, Vector<mixed> $args): mixed {
        $loxInstance = new LoxInstance($this);
        return $loxInstance;
    }

    public function arity(): int {
        return 0;
    }
}
