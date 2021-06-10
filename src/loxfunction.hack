namespace Lox;

class LoxFunction implements LoxCallable {
    public function __construct(private Func $fun) {}

    public function arity(): num {
        return \count($this->fun->params); 
    }

    public function call(Interpreter $in, Vector<mixed> $params): mixed {
        $localEnv = new Environment(dict[], $in->globals);
        for ($i = 0; $i < \count($params); $i++) {
            $localEnv->define($this->fun->params->at($i)->lexeme(),
             $params->at($i));
        }
        $in->executeBlock(new Block($this->fun->body), $localEnv);
        return NULL;
    }

    public function __toString(): string {
        return '<fn ' . $this->fun->name->lexeme() . '>';
    }
}