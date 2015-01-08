#!/usr/bin/sed -nf
/^$/d
H
/^\r$/{
    x
        # Remove leading newline introduced by adding to empty hold space
        s/^\n//
        # Escape slashes and pipes
        s/[\|]/\\&/g
        # Replace linebreaks
        s/\r\n\|\r\|\n/|/g
        # Wrap into request "data structure"
        s/^.*$/|Request:&/
    x

    # Build basic response headers
    x
        s/$/|ResponseHeaders:/
        s/$/HTTP\/1.0 200 OK\r\n/
        s/$/Server: SED\r\n/
        s/$/Connection: Close\r\n/
        s/$/\r|/
    x

    # Some rewriting...
    g

    s/^|Request:GET \/ /|Request:GET \/index.html /

    # Handle static files
    /^|Request:GET \/index.html /{
        s/\(.*|||ResponseHeaders:[^|]*\n\)\r|/\1Content-Type: text\/html; charset=utf-8\r\n\r|/
        s/.*|||ResponseHeaders:\(.*\)|/\1/;p
        r static/index.html
        q
    }
    /^|Request:GET \/favicon.ico /{
        s/\(.*|||ResponseHeaders:[^|]*\n\)\r|/\1Content-Type: image\/x-icon\r\n\r|/
        s/.*|||ResponseHeaders:\(.*\)|/\1/;p
        r static/favicon.ico
        q
    }
    /^|Request:GET \/style.css /{
        s/\(.*|||ResponseHeaders:[^|]*\n\)\r|/\1Content-Type: text\/css\r\n\r|/
        s/.*|||ResponseHeaders:\(.*\)|/\1/;p
        r static/style.css
        q
    }
    /^|Request:GET \/game\/level\([1-9]\|[1-8][0-9]\|90\)\/[hjkl]* /{
        s/\(.*|||ResponseHeaders:[^|]*\n\)\r|/\1Content-Type: text\/plain\r\n\r|/
        s/.*|||ResponseHeaders:\(.*\)|/\1/;p
        bgame
    }
    # Default to 404
        s/\(.*|||ResponseHeaders:[^|]*\n\)\r\n|/\1Content-Type: text\/html; charset=utf-8\r\n|/
        s/\(ResponseHeaders:HTTP\/1.0\) 200 OK/\1 404 Not found/
        s/.*|||ResponseHeaders:\(.*\)|/\1/;p
        r static/404.html
        q
    q
}

d

:game

i\
Game!

# Count number of moves
    g
    s/|Request:GET \/game\/level\([0-9]*\)\/\([hjkl]*\) .*/\2/
    s/[hjkl]/#/g
    s/$/0/


    :count_loop1

    # Reset OR
    s/$//
    tcount_if1
    :count_if1

    # Check whether we want to continue or not...
    s/^#/#/
    # GNU extension
    Tcount_end

    # replace all trailing 9s by _ (any other character except digits, could
    # be used)
    :count_d
    s/9\(_*\)$/_\1/
    tcount_d

    # incr last digit only.  The first line adds a most-significant
    # digit of 1 if we have to add a digit.
    #
    # The tn commands are not necessary, but make the thing
    # faster

    s/\(^\|#\)\(_*\)$/\11\2/; tcount_n
    s/8\(_*\)$/9\1/; tcount_n
    s/7\(_*\)$/8\1/; tcount_n
    s/6\(_*\)$/7\1/; tcount_n
    s/5\(_*\)$/6\1/; tcount_n
    s/4\(_*\)$/5\1/; tcount_n
    s/3\(_*\)$/4\1/; tcount_n
    s/2\(_*\)$/3\1/; tcount_n
    s/1\(_*\)$/2\1/; tcount_n
    s/0\(_*\)$/1\1/; tcount_n

    :count_n
    y/_/0/

    s/^[#]//
    tcount_loop1
    :count_end

    H;g
    s/\n\([0-9]*\)$/|Moves:\1|/
    h

# END: Count

g
s/|Request:GET \/game\/level\([0-9]*\)\/\([hjkl]*\) .*|Moves:\([0-9]*\)|.*/Sekoban! (level: \1, moves: \3)/p

q
