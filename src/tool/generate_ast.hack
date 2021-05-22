#! /usr/bin/env hhvm
namespace Lox\Tool;

use namespace HH\Lib\{C};

<<__EntryPoint>>
async function main_async(): Awaitable<void> {
    $argv = vec(\HH\global_get('argv') as Container<_>);

    $len = C\count($argv);
    if ($len <= 1) {
        \printf("Usage: generate_ast <output_dir>\n");
        exit(64);
    }

    $outputDir = (string)$argv[1];

}

async function define_ast_async(
    string $_outputDir,
    string $_baseName,
    Vector<string> $_types,
): Awaitable<void> {

}
