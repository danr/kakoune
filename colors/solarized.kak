# solarized theme

try %{
  decl bool solarized_light true
}

%sh{
    # Base color definitions
    if [[ "$kak_opt_solarized_light" == "false" ]]; then
        # base03="rgb:002b36"
        # base02="rgb:073642"
        base03="rgb:1c1c1c"
        base02="rgb:2a2a2a"
        base01="rgb:586e75"
        base00="rgb:657b83"
        base0="rgb:839496"
        base1="rgb:93a1a1"
        base2="rgb:eee8d5"
        base3="rgb:fdf6f3"

        yellow="rgb:b58900"
        orange="rgb:cb4b16"
        red="rgb:dc322f"
        magenta="rgb:d33682"
        violet="rgb:6c71c4"
        blue="rgb:268bd2"
        cyan="rgb:2aa198"
        green="rgb:859900"

    else
        base3="rgb:002b36"
        base2="rgb:073642"

        base3="rgb:1c1c1c"
        base2="rgb:2a2a2a"

        base1="rgb:384e55"
        base0="rgb:657b83"
        base00="rgb:839496"
        base01="rgb:93a1a1"
        base02="rgb:eee8d5"
        base03="rgb:ffffff"

        yellow="rgb:b58900"
        orange="rgb:cb4b16"
        red="rgb:dc322f"
        magenta="rgb:d33682"
        violet="rgb:6c71c4"
        blue="rgb:268bd2"
        cyan="rgb:2aa198"
        green="rgb:859900"

    fi

    echo "
        # then we map them to code
        face value      ${cyan}
        face variable   ${violet}
        face attribute  ${violet}
        face keyword    ${blue}
        face identifier ${base00}
        face type       ${cyan}
        face string     ${magenta}
        face builtin    ${violet}
        face meta       ${violet}
        face comment    ${yellow}
        face docstring  ${orange}

        # and markup
        face title      ${yellow}
        face header     ${blue}
        face bold       ${base1}
        face italic     ${base2}
        face mono       ${base3}
        face block      ${violet}
        face link       ${magenta}
        face bullet     ${orange}
        face list       ${yellow}

        # and built in faces
        face Default            ${base2},${base03}
        face PrimaryCursor      ${base03},${magenta}
        face PrimarySelection   ${base03},${cyan}
        face SecondaryCursor    ${base03},${base2}
        face SecondarySelection ${base03},${base0}
        face LineNumbers        ${base0},${base02}
        face LineNumberCursor   ${base2},${base02}
        face MenuBackground     ${base1},rgb:e8eee2
        face MenuForeground     ${base03},${blue}
        face MenuInfo           ${base2},rgb:e8eee2
        face Information        ${magenta},rgb:e8eee2
        face Error              ${red}+b
        face StatusLine         ${base1},${base03}
        face StatusLineMode     ${violet}
        face StatusLineInfo     ${magenta}
        face StatusLineValue    ${base0}
        face StatusCursor       default+r
        face Prompt             ${base0},${base03}
        face MatchingChar       ${magenta},rgb:e8eee2
        # default+b
        face BufferPadding      ${base01},${base03}

        # default,${base03}
    "
}
