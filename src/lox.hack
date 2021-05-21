#! /usr/bin/env hhvm
namespace Lox;

use namespace HH\Lib\{C, File, IO};

<<__EntryPoint>>
async function main(): Awaitable<void> {
    require_once(__DIR__.'/../vendor/autoload.hack');
    \Facebook\AutoloadMap\initialize();
    $argv = vec(\HH\global_get('argv') as Container<_>);

    $len = C\count($argv);
    \printf("Length of argv: %d\n", $len);
    if ($len < 1) {
        \printf("Usage: lox [script]\n");
        exit(64);
    } else if ($len == 2) {
        await Lox::runFile((string) $argv[1]);
    } else {
        await Lox::runPrompt();
    }
}

class Lox {
    static bool $had_error = false;

    public static async function runPrompt(): Awaitable<void> {
        $_in = IO\request_input();
        $_reader = new IO\BufferedReader($_in);
        for(;;) {
            \printf('> ');
            $line = await $_reader->readLineAsync();
            if ($line == NULL) break;
            Lox::run($line);
            Lox::$had_error = false;
        }
    }

    public static async function runFile(string $filename): Awaitable<void> {
        \printf("Running %s\n", $filename);
        $handle = NULL;
        try {
            $handle = File\open_read_only($filename);
            $source = await $handle->readAllAsync();
            Lox::run($source);
            if (Lox::$had_error) {
                exit(65);
            }
        } catch (\Exception $ex) {
            echo $ex->getMessage() . "\n";
        } finally {
            if ($handle != NULL) {
                echo "Closing file handle.\n";
                $handle->close();
            }
        }
    }

    public static function run(string $source): int {
        $scanner = new Scanner($source);
        $tokens = $scanner->scanTokens();
        foreach ($tokens as $token) {
            \printf("%s\n", $token->lexeme());
        }
        return 0;
    }
    public static function error(int $line, string $message): void {
        Lox::report($line, '', $message);
    }

    private static function report(int $line, string $where, string $message): void {
        \printf('[line %d] Error%s: %s', $line, $where, $message);
    }
}

class Token {
    public TokenType $type;
    public string $lexeme;
    public ?Object $literal;
    public int $line;

    public function __construct(string $lexeme,
                                TokenType $type,
                                int $line,
                                ?Object $literal = NULL) {

        $this->lexeme = $lexeme;
        $this->type = $type;
        $this->literal = $literal;
        $this->line = $line;
    }

    public function lexeme(): string {
        return $this->lexeme;
    }
}

class Object {

}
