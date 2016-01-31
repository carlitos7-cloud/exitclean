module exitclean;
class ExitException : Exception
{
    int code;
    string funcName;

    this(int code, string msg = null,
        string file = __FILE__, size_t line = __LINE__,
        string funcName = __PRETTY_FUNCTION__)
    {
        this.code = code;
        this.funcName = funcName;
        super(msg, file, line);
    }
}

private ubyte[__traits(classInstanceSize, ExitException)] exitExceptionBuffer;

void exit(int code, string msg = null,
    string file = __FILE__, size_t line = __LINE__,
    string funcName = __PRETTY_FUNCTION__)
{
    if (exitExceptionBuffer != typeof(exitExceptionBuffer).init)
        assert(0); //no support for chaining ExitExceptions
    import std.conv : emplace;
    throw emplace!ExitException(exitExceptionBuffer,
        code, msg, file, line, funcName);
}

debug version = ShowExitLoc;
version (ShowExitTrace) version = ShowExitLoc;

mixin template Main(alias codeMain)
{
    int main(string[] args)
    {
        import std.meta : AliasSeq;
        import std.traits : Parameters, ReturnType;
        static if (is(Parameters!codeMain[0] == string[]))
            alias codeMainArgs = args;
        else
            alias codeMainArgs = AliasSeq!();

        try {
            static if (is(ReturnType!codeMain == int))
                return codeMain(codeMainArgs);
            else
            {
                codeMain(codeMainArgs);
                return 0;
            }
        }
        catch (ExitException e)
        {
            version (ShowExitLoc)
            {
                import std.stdio : stderr;
                stderr.writeln("Exitting from ", e.funcName,
                    " @ ", e.file, "(", e.line, ") with message: \"", e.msg, "\"");
            }
            version (ShowExitTrace)
                if (e.info)
                    foreach(t; e.info)
                        stderr.writeln(t);
            return e.code;
        }
    }
}
