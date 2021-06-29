namespace Lox;

class LoxInstance {
    public function __construct(private LoxClass $klass) {}
    public function __toString(): string {
        return $this->klass->name . ' instance';
    }
}
