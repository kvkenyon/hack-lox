#! /usr/bin/env hhvm
namespace Lox\Tool;

use namespace HH\Lib\{C,File, IO, Str};

<<__EntryPoint>>
async function main_async(): Awaitable<void> {
    $argv = vec(\HH\global_get('argv') as Container<_>);

    $len = C\count($argv);
    if ($len <= 1) {
        \printf("Usage: generate_ast <output_dir>\n");
        exit(64);
    }

    $outputDir = (string) $argv[1];
    $typesExpr = vec<string>[
      'Ternary  : Expr $a, Expr $b, Expr $c',
      'Binary   : Expr $left, Token $operator, Expr $right',
      'Call     : Expr $calle, Token $paren, Vector<Expr> $arguments',
      'Grouping : Expr $expression',
      'Literal  : Object $value',
      'Lambda   : Vector<Token> $params, Vector<Stmt> $body',
      'Unary    : Token $operator, Expr $right',
      'Variable : Token $name',
      'Assign   : Token $name, Expr $value'
      ];

    await define_ast_async($outputDir, 'Expr', $typesExpr);

    $typesStmt = vec<string> [
        'Expression : Expr $expression',
        'Show       : Expr $expression',
        'VarDecl    : Token $name, ?Expr $initializer',
        'Block      : Vector<Stmt> $statements',
        'IfElse     : Expr $condition, Stmt $thenBranch, ?Stmt $elseBranch',
        'WhileLoop  : Expr $condition, Stmt $body',
        'Func   : Token $name, Vector<Token> $params, Vector<Stmt> $body',
        'Ret    : Token $keyword, ?Expr $value',
        'Classy   : Token $name, Vector<Func> $methods'
    ];

    await define_ast_async($outputDir, 'Stmt', $typesStmt);

    await define_visitors_async($outputDir, vec<string>['Expr', 'Stmt'], vec<vec<string>>[$typesExpr, $typesStmt]);
}

async function define_ast_async(
    string $_outputDir,
    string $_baseName,
    vec<string> $_types,
): Awaitable<void> {
    $path = $_outputDir . '/' . $_baseName . '.hack';
    $_out = IO\request_output();

    $printer = new PrintWriter('');

    $printer->println('namespace Lox;');
    $printer->println('');
    $printer->println('abstract class ' . $_baseName . ' {');
    $printer->println('    abstract public function accept<T>(Visitor<T> $visitor): T;');
    $printer->println('}');
    $printer->println('');

    foreach ($_types as $type) {
        $className = Str\trim(Str\split($type, ':')[0]);
        $fields = Str\trim(Str\split($type, ':')[1]);
        define_type($printer, $_baseName, $className, $fields);
        $printer->println('');
    }

    $writer = File\open_write_only($path);
    await $writer->writeAllAsync($printer->value());
    $writer->close();
}

function define_type(PrintWriter $printer,
    string $baseName,
    string $className,
    string $fieldVec): void {
    $printer->println('class ' . $className . ' extends ' . $baseName . ' {');

    $fields = Str\split($fieldVec, ',');

    foreach ($fields as $field) {
        $field = Str\trim($field);
        $printer->println('    public ' . $field . ';');
    }

    $printer->println('    public function __construct(' . $fieldVec . ') {');

    foreach ($fields as $field) {
        $field = Str\trim($field);
        $varName = Str\slice(Str\split($field, ' ')[1], 1);
        $printer->println('        $this->' . $varName . ' = ' . '$' . $varName . ';');
    }

    $printer->println('    }');
    $printer->println('');
    $printer->println('    <<__Override>>');
    $printer->println('    public function accept<T>(Visitor<T> $visitor): T {');
    $printer->println('        return $visitor->visit' . $className . $baseName . '($this);');
    $printer->println('    }');

    $printer->println('}');
}

async function define_visitors_async(string $outputDir,
        vec<string> $baseNames,
        vec<vec<string>> $typesList): Awaitable<void>{
    $path = $outputDir . '/Visitor.hack';
    $_out = IO\request_output();

    $printer = new PrintWriter('');

    $printer->println('namespace Lox;');

    $printer->println('interface Visitor<T> {');

    $i = 0;
    foreach ($baseNames as $baseName) {
        $types = $typesList[$i];
        foreach ($types as $type) {
            $typeName = Str\trim(Str\split($type, ':')[0]);
            $printer->println('    public function visit' . $typeName . $baseName . '(' . $typeName . ' $' . Str\lowercase($baseName) . '): T;' );
        }
        ++$i;
    }
    $printer->println('}');
    $writer = File\open_write_only($path);
    await $writer->writeAllAsync($printer->value());
    $writer->close();
}

class PrintWriter {
    private string $source;

    public function __construct(string $source) {
        $this->source = $source;
    }

    public function println(string $s): void {
        $this->source .= $s . "\n";
    }

    public function value(): string {
        return $this->source;
    }

}
