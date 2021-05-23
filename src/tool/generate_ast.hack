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
    $types = vec<string>[
      'Binary   : Expr $left, Token $operator, Expr $right',
      'Grouping : Expr $expression',
      'Literal  : Object $value',
      'Unary    : Token $operator, Expr $right'];

    await define_ast_async($outputDir, 'Expr', $types);
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
        $printer->println('    private ' . $field . ';');
    }

    $printer->println('    public function __construct(' . $fieldVec . ') {');

    foreach ($fields as $field) {
        $field = Str\trim($field);
        $varName = Str\slice(Str\split($field, ' ')[1], 1);
        $printer->println('        $this->' . $varName . ' = ' . '$' . $varName . ';');
    }

    $printer->println('    }');

    $printer->println('}');
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
