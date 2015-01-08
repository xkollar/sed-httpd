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
g
s/|Request:GET \/game\/level\([0-9]*\)\/\([hjkl]*\) .*/Sekoban! (level: \1, moves: "\2")/p
q
