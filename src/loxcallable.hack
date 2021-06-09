namespace Lox;

interface LoxCallable {
    public function call(Interpreter $interpreter, Vector<mixed> $args): mixed;
    public function arity(): num;
}
