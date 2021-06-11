namespace Lox;

class LoxFunction implements LoxCallable {
    public function __construct(private Func $fun, private Environment $closure) {}

    public function arity(): num {
        return \count($this->fun->params); 
    }

    public function call(Interpreter $in, Vector<mixed> $params): mixed {
        $localEnv = new Environment(dict[], $this->closure);
        for ($i = 0; $i < \count($params); $i++) {
            $localEnv->define($this->fun->params->at($i)->lexeme(),
             $params->at($i));
        }
        try {
            $in->executeBlock(new Block($this->fun->body), $localEnv);
        } catch (ReturnException $ret) {
            return $ret->value;
        }
        return NULL;
    }

    public function __toString(): string {
        return '<fn ' . $this->fun->name->lexeme() . '>';
    }
}

class LoxLambda implements LoxCallable {
    public function __construct(private Lambda $lambda, private Environment $closure) {}
    public function arity(): num {
        return \count($this->lambda->params);
    }
    public function call(Interpreter $in, Vector<mixed> $params): mixed {
        $localEnv = new Environment(dict[], $this->closure);
        for ($i = 0; $i < \count($params); $i++) {
            $localEnv->define($this->lambda->params->at($i)->lexeme(),
             $params->at($i));
        }
        try {
            $in->executeBlock(new Block($this->lambda->body), $localEnv);
        } catch (ReturnException $ret) {
            return $ret->value;
        }
        return NULL;
    }
    public function __toString(): string {
        return '<lambda>';
    }
}