#!/usr/bin/sed -nf
#
# Sed server
# ----------
#
# Author: Matej Kollar <208115@mail.muni.cz>
#
# Sokoban example taken from sokoban.sed by aurélio marinho jargas
#
#     * http://aurelio.net/projects/sedsokoban/
#     * https://github.com/aureliojargas/sokoban.sed
#     * http://sed.sourceforge.net/grabbag/scripts/sokoban.sed
#
# Number incrementation taken from GNU sed documentation
#
#     * https://www.gnu.org/software/sed/manual/sed.html#Examples
#
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
        s/\(.*|||ResponseHeaders:[^|]*\n\)\r|/\1Content-Type: text\/html\r\n\r|/
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
<!DOCTYPE html>\
<html\
><head\
    ><title>SED Sokoban<\/title\
    ><link rel="shortcut icon" type="image/x-icon" href="/favicon.ico"\
    ><link rel="stylesheet" type="text/css" href="/style.css"\
/></head\
><body>

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

# Status line
g
s/|Request:GET \/game\/level\([0-9]*\)\/\([hjkl]*\) .*|Moves:\([0-9]*\)|.*/\
<div><h1>SED Sokoban<\/h1> <div>(level: \1, moves: \3)<\/div><\/div>\
/p

# Controlling elements
g
s/|Request:GET \/game\/level\([0-9]*\)\/\([hjkl]*\) .*/\
<a href="\/game\/level\1\/\2h" accesskey="h">left<\/a>\
<a href="\/game\/level\1\/\2j" accesskey="j">down<\/a>\
<a href="\/game\/level\1\/\2k" accesskey="k">up<\/a>\
<a href="\/game\/level\1\/\2l" accesskey="l">right<\/a>\
/p

i\
<pre>

g
s/|Request:GET \/game\/level\([0-9]*\)\/.*/\1/

x
s/|Request:GET \/game\/level\([0-9]*\)\/\([hjkl]*\) .*/\2/
x

#r loading map

#r --------------------
  /^1$/s/.*/\
SED Sokoban - LEVEL 1\
\
     %%%%%            \
     %   %            \
     %o  %            \
   %%%  o%%           \
   %  o o %           \
 %%% % %% %   %%%%%%  \
 %   % %% %%%%%  ..%  \
 % o  o          ..%  \
 %%%%% %%% %@%%  ..%  \
     %     %%%%%%%%%  \
     %%%%%%%          \
\
\
\
\
\
\
/
#r --------------------
  /^2$/s/.*/\
SED Sokoban - LEVEL 2\
\
 %%%%%%%%%%%%         \
 %..  %     %%%       \
 %..  % o  o  %       \
 %..  %o%%%%  %       \
 %..    @ %%  %       \
 %..  % %  o %%       \
 %%%%%% %%o o %       \
   % o  o o o %       \
   %    %     %       \
   %%%%%%%%%%%%       \
\
\
\
\
\
\
\
/
#r --------------------
  /^90$/s/.*/\
SED Sokoban - LEVEL 90\
\
 %%%%%%%%%%%%%%%%%%%% \
 %..%    %          % \
 %.o  o  %oo  o%% o%% \
 %.o%  %%%  %% %%   % \
 %  % o %  oo   o   % \
 % %%%  % %  %o  %%%% \
 %  %% % o   %@ %   % \
 % o    o  %%.%%  o % \
 %  % o% o% o     %%% \
 %  %  %  %   %%%   % \
 %  %%%%%%%% %      % \
 %           %  %.%.% \
 %%o%%%%%%%%o%   ...% \
 %    .*  %    %%.%.% \
 % .*...*   o  .....% \
 %%%%%%%%%%%%%%%%%%%% \
                      \
/

/SED Soko/!{s/.*/there is no '&' level!/p;q;}

x
#r here the party begins
:ini

#r wipe trash
s/[^kjlh]//g

#r -------------[ LEFT ]--------------------------

/^h/{

#r del current move and save others
  s///;x

#r clear path
  / @/{s//@ /;bx;}
#r push load
  / o@/{s//o@ /;bx;}

#r enter overdot
  /\.@/{s//! /;bx;}
#r continue overdot
  /\.!/{s//!./;bx;}
#r out overdot
  / !/{s//@./;bx;}

#r enter load overdot
  /\.o@/{s//O@ /;bx;}
#r enter overdot with load
  /\.O@/{s//O! /;bx;}
#r continue overdot with load
  /\.O!/{s//O!./;bx;}
#r out load overdot / enter overdot
  / O@/{s//o! /;bx;}
#r out load overdot / continue overdot
  / O!/{s//o!./;bx;}
#r out overdot with load
  / o!/{s//o@./;bx;}
#r out overdot with load / enter overdot
  /\.o!/{s//O@./;bx;}

#r can't pass
  bx

}


#r -------------[ RIGHT ]-------------------------

/^l/{

#r del current move and save others
  s///;x

#r clear path
  /@ /{s// @/;bx;}
#r push load
  /@o /{s// @o/;bx;}

#r enter overdot
  /@\./{s// !/;bx;}
#r continue overdot
  /!\./{s//.!/;bx;}
#r out overdot
  /! /{s//.@/;bx;}

#r enter load overdot
  /@o\./{s// @O/;bx;}
#r enter overdot with load
  /@O\./{s// !O/;bx;}
#r continue overdot with load
  /!O\./{s//.!O/;bx;}
#r out load overdot / enter overdot
  /@O /{s// !o/;bx;}
#r out load overdot / continue overdot
  /!O /{s//.!o/;bx;}
#r out overdot with load
  /!o /{s//.@o/;bx;}
#r out overdot with load / enter overdot
  /!o\./{s//.@O/;bx;}

#r can't pass
  bx
}


#r -------------[ DOWN ]--------------------------

/^j/{

#r del current move and save others
  s///;x

#r clear path
  /@\(.\{22\}\) /{s// \1@/;bx;}
#r push load
  /@\(.\{22\}\)o\(.\{22\}\) /{s// \1@\2o/;bx;}

#r enter overdot
  /@\(.\{22\}\)\./{s// \1!/;bx;}
#r continue overdot
  /!\(.\{22\}\)\./{s//.\1!/;bx;}
#r out overdot
  /!\(.\{22\}\) /{s//.\1@/;bx;}

#r enter load overdot
  /@\(.\{22\}\)o\(.\{22\}\)\./{s// \1@\2O/;bx;}
#r enter overdot with load
  /@\(.\{22\}\)O\(.\{22\}\)\./{s// \1!\2O/;bx;}
#r continue overdot with load
  /!\(.\{22\}\)O\(.\{22\}\)\./{s//.\1!\2O/;bx;}
#r out load overdot / enter overdot
  /@\(.\{22\}\)O\(.\{22\}\) /{s// \1!\2o/;bx;}
#r out load overdot / continue overdot
  /!\(.\{22\}\)O\(.\{22\}\) /{s//.\1!\2o/;bx;}
#r out overdot with load
  /!\(.\{22\}\)o\(.\{22\}\) /{s//.\1@\2o/;bx;}
#r out overdot with load / enter overdot
  /!\(.\{22\}\)o\(.\{22\}\)\./{s//.\1@\2O/;bx;}

#r target not free
  bx
}


#r ---------------[ UP ]--------------------------

/^k/{

#r del current move and save others
  s///;x

#r clear path
  / \(.\{22\}\)@/{s//@\1 /;bx;}
#r push load
  / \(.\{22\}\)o\(.\{22\}\)@/{s//o\1@\2 /;bx;}

#r enter overdot
  /\.\(.\{22\}\)@/{s//!\1 /;bx;}
#r continue overdot
  /\.\(.\{22\}\)!/{s//!\1./;bx;}
#r out overdot
  / \(.\{22\}\)!/{s//@\1./;bx;}

#r enter load overdot
  /\.\(.\{22\}\)o\(.\{22\}\)@/{s//O\1@\2 /;bx;}
#r enter overdot with load
  /\.\(.\{22\}\)O\(.\{22\}\)@/{s//O\1!\2 /;bx;}
#r continue overdot with load
  /\.\(.\{22\}\)O\(.\{22\}\)!/{s//O\1!\2./;bx;}
#r out load overdot / enter overdot
  / \(.\{22\}\)O\(.\{22\}\)@/{s//o\1!\2 /;bx;}
#r out load overdot / continue overdot
  / \(.\{22\}\)O\(.\{22\}\)!/{s//o\1!\2./;bx;}
#r out overdot with load
  / \(.\{22\}\)o\(.\{22\}\)!/{s//o\1@\2./;bx;}
#r out overdot with load / enter overdot
  /\.\(.\{22\}\)o\(.\{22\}\)!/{s//O\1@\2./;bx;}

#r target not free
  bx
}

#r wrong command, do nothing
x


#r ----------------[ THE END ]-----------------
:x

#r adding color codes
#s/%/[43;33m&[m/g
s/%/[46;36m&[m/g
s/[!@]/[33;1m&[m/g
s/O/[37;1m&[m/g
s/\./[31;1m&[m/g

#r uncomment this line if you DON'T want colorized output (why not?)
s/\[[0-9;]*m//g

#r removing color codes from maze
s/\[[0-9;]*m//g

#r no more load ('o'), level finished!
/LEVEL \([1-9]\|[1-8][0-9]\)[^0-9]/{
/[ @!%.]o\|o[ @!%.]/!{
s/LEVEL \([0-9]*\).*$/&\n     (( SUCCESS! ))     \
\
 Next level: \1/

    # replace all trailing 9s by _ (any other character except digits, could
    # be used)
    :inc_d
    s/9\(_*\)$/_\1/
    tinc_d

    # incr last digit only.  The first line adds a most-significant
    # digit of 1 if we have to add a digit.
    #
    # The tn commands are not necessary, but make the thing
    # faster

    s/\(l\)\(_*\)$/\11\2/; tinc_n
    s/8\(_*\)$/9\1/; tinc_n
    s/7\(_*\)$/8\1/; tinc_n
    s/6\(_*\)$/7\1/; tinc_n
    s/5\(_*\)$/6\1/; tinc_n
    s/4\(_*\)$/5\1/; tinc_n
    s/3\(_*\)$/4\1/; tinc_n
    s/2\(_*\)$/3\1/; tinc_n
    s/1\(_*\)$/2\1/; tinc_n
    s/0\(_*\)$/1\1/; tinc_n

    :inc_n
    y/_/0/

s/Next level: \([0-9]*\)$/ <a href="\/game\/level\1\/">Continue to level \1!<\/a>/

p
bexit
}
}
/[ @!%.]o\|o[ @!%.]/!{s/$/     (( VICTORY! ))     /p;bexit;}

#r save current position on hold space
x

# #r skipping loop
# 2d

#r nice loop for accumulated moves
/./{bini;}
#r Render current state
x;p

:exit
i\
</pre>\
</body>\
</html>
q
