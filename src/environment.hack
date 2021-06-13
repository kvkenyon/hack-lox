namespace Lox;

use namespace HH\Lib\C;

class Environment {
    public function __construct(
        private dict<string, mixed> $environ = dict[],
        private ?Environment $enclosing = NULL) {}

    public function define(string $name, mixed $value): void {
        $this->environ[$name] = $value;
    }

    public function get(Token $name): mixed {
        if (C\contains_key($this->environ, $name->lexeme())) {
            return $this->environ[$name->lexeme()];
        } else if ($this->enclosing !== NULL) {
            return $this->enclosing->get($name);
        }

        throw new RuntimeError($name, 'Undefined variable ' . $name->lexeme() . '.');
    }

    public function getAt(num $depth, string $name): mixed {
       return $this->ancestor($depth)->environ[$name]; 
    }

    public function ancestor(num $depth): Environment {
        $env = $this;
        for ($i = 0; $i < $depth; $i++) {
            if ($env->enclosing !== NULL) {
                $env = $env->enclosing;
            }         
        }
        return $env;
    }

    public function assign(Token $name, mixed $value): void {
        if (C\contains_key($this->environ, $name->lexeme())) {
            $this->environ[$name->lexeme()] = $value;
            return;
        } else if ($this->enclosing !== NULL) {
            $this->enclosing->assign($name, $value);
            return;
        }

        throw new RuntimeError($name, 'Undefined variable ' . $name->lexeme() . '.');
    }

    public function assignAt(num $depth, string $name, mixed $value): void {
        $this->ancestor($depth)->environ[$name] = $value;
    }
}
