# exitclean

For simple programs (and even some less simple), C's `exit` function from `stdlib.h` is very convenient. You can use it in D (`import core.stdc.stdlib;`), but it's not going to run any destructors or terminate the runtime cleanly.

`exitclean` deals with this by throwing a custom exception, so all stacks are appropriately unwound. Use it like this:

```D
import exitclean;

void foo()
{
    if (somethingsWrong)
        exit(1);
}
```

You can then catch the `ExitException` yourself in your `main`, extract the exit code (available as a member `code` of the exception and return it.

In order to save effort, `exitclean` also defines a mixin template to generate a main for you that deals with the `try/catch` and `return` automagically. Use like this:

```D
void myMain()
{
    // Your program here
}

mixin Main!myMain;
```

or like this:

```D
mixin Main!((string[] args)
{
    // Your program here
});
```

All that's required is that the function you provide to `Main` takes either nothing or `string[]` and returns either `void` or `int`.

## Options
There are 2 `version`s that affect the behaviour of `Main`. `ShowExitLoc` causes the function name, file and line where `exit` was called from to be printed to `stderr` before exiting. `ShowExitTrace` causes a full stack trace to be printed to `stderr`. `ShowExitLoc` is enabled by default in `debug` builds.

## Caveats
Because we are using an exception, `exit` will trigger any `scope(failure)` clauses on the way up the stack.
`exit` will be blocked by any `catch(Exception)` statement on the way up the stack. If this is a problem for you, I suggest forking this project and changing `ExitException` to inherit from `Throwable` instead of `Exception`.
