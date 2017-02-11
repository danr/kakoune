# http://python.org
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](py) %{
    set buffer filetype python
}

# Highlighters & Completion
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -group / regions -default code python \
    kak           '"""\h*#\h*kak' '"""'      '' \
    kak           "'''\h*#\h*kak" "'''"      '' \
    double_docstr '"""' '"""'            '' \
    single_docstr "'''" "'''"            '' \
    double_string '"'   (?<!\\)(\\\\)*"  '' \
    single_string "'"   (?<!\\)(\\\\)*'  '' \
    comment       '#'   '$'              ''

add-highlighter -group /python/kak           ref kakrc
add-highlighter -group /python/double_string fill string
add-highlighter -group /python/single_string fill string
add-highlighter -group /python/double_docstr fill docstring
add-highlighter -group /python/single_docstr fill docstring
add-highlighter -group /python/comment       fill comment

add-highlighter -group /python/code regex '\b(import)\h+\S+\h+(as)\b' 1:meta 2:meta

%sh{
    # Grammar
    values="True|False|None"
    meta="import|from"
    # Keyword list is collected using `keyword.kwlist` from `keyword`
    keywords="and|as|assert|break|class|continue|def|del|elif|else|except|exec"
    keywords="${keywords}|finally|for|global|if|in|is|lambda|not|or|pass|print"
    keywords="${keywords}|raise|return|try|while|with|yield"
    types="bool|buffer|bytearray|bytes|complex|dict|file|float|frozenset|int"
    types="${types}|list|long|memoryview|object|set|str|tuple|unicode|xrange"
    functions="abs|all|any|ascii|bin|callable|chr|classmethod|compile|complex"
    functions="${functions}|delattr|dict|dir|divmod|enumerate|eval|exec|filter"
    functions="${functions}|format|frozenset|getattr|globals|hasattr|hash|help"
    functions="${functions}|hex|id|__import__|input|isinstance|issubclass|iter"
    functions="${functions}|len|locals|map|max|memoryview|min|next|oct|open|ord"
    functions="${functions}|pow|print|property|range|repr|reversed|round"
    functions="${functions}|setattr|send|slice|sorted|staticmethod|sum|super|type|vars|zip"

    # Add the language's grammar to the static completion list
    printf %s\\n "hook global WinSetOption filetype=python %{
        set window static_words '${values}:${meta}:as:${keywords}:${types}:${functions}'
    }" | sed 's,|,:,g'

    printf %s "
        add-highlighter -group /python/code regex '\b(except|with)\b((?!import).)*?\b(as)\b' 3:keyword
    "

    # Highlight keywords
    printf %s "
        add-highlighter -group /python/code regex '\b(${values})\b' 0:value
        add-highlighter -group /python/code regex '\b(${meta})\b' 0:meta
        add-highlighter -group /python/code regex '\b(${keywords})\b' 0:keyword
        add-highlighter -group /python/code regex '(?<!\.)\b(${functions})\b\(' 1:builtin
    "

    # Highlight types and attributes
    printf %s "
        add-highlighter -group /python/code regex '(?<!\.)\b(${types})\b' 0:type
        add-highlighter -group /python/code regex '@[\w_]+\b' 0:attribute
    "
}

add-highlighter -group /python/code regex (?<=[\w\s\d'"_])(<=|<<|>>|>=|<>|<|>|!=|==|\||\^|&|\+|-|\*\*|\*|//|/|%|~) 0:operator
add-highlighter -group /python/code regex (?<=[\w\s\d'"_])((?<![=<>!])=(?![=])|[+*-]=) 0:builtin

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden python-indent-on-new-line %{
    eval -draft -itersel %{
        # copy '#' comment prefix and following white spaces
        # try %{ exec -draft k <a-x> s ^\h*#\h* <ret> y jgh P }
        # preserve previous line indent
        try %{ exec -draft \; K <a-&> }
        # cleanup trailing whitespaces from previous line
        try %{ exec -draft k <a-x> s \h+$ <ret> d }
        # indent after line ending with :
        try %{ exec -draft <space> k x <a-k> :$ <ret> j <a-gt> }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group python-highlight global WinSetOption filetype=python %{ add-highlighter ref python }

hook global WinSetOption filetype=python %{
    hook window InsertChar \n -group python-indent python-indent-on-new-line
    # cleanup trailing whitespaces on current line insert end
    hook window InsertEnd .* -group python-indent %{ try %{ exec -draft \; <a-x> s ^\h+$ <ret> d } }
}

hook -group python-highlight global WinSetOption filetype=(?!python).* %{ remove-highlighter python }

hook global WinSetOption filetype=(?!python).* %{
    remove-hooks window python-indent
}
