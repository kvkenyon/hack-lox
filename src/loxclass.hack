namespace Lox;

class LoxClass {
    public function __construct(private string $name) {}
    public function __toString(): string {
        return $this->name;
    }
}
