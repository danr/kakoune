
decl -hidden str jedi_loc %sh{echo $(dirname $kak_source)}

def jedi-start %{

    decl -docstring "The python interpreter to use. You can set this and then run jedi-restart." str python python

    def -hidden jedi-spawn %{ %sh{
        (
            $kak_opt_python $kak_opt_jedi_loc/jedikak.py $kak_opt_jedi_dir
        ) > $kak_opt_jedi_dir/stdout 2> $kak_opt_jedi_dir/stderr < /dev/null &
        echo set global jedi_proc $! | kak -p $kak_session
    } }

    decl -hidden str jedi_proc
    decl -hidden str jedi_dir
    decl -hidden completions jedi_completions

    %sh{
        dir=$(mktemp -d -t kak-jedi.XXXXXXXX)
        mkfifo ${dir}/fifo
        echo set global jedi_dir $dir
    }

    jedi-spawn

    def jedi-stop %{
        %sh{
            kill $kak_opt_jedi_proc
            rm -rf $kak_opt_jedi_dir
        }
        def -allow-override -params .. jedi nop
    }

    def jedi-restart %{
        %sh{
            kill $kak_opt_jedi_proc
        }
        jedi-spawn
    }

    def -params 1 jedi %{
        eval -no-hooks write %sh{ echo $kak_opt_jedi_dir/buf }
        %sh{
            echo $1:$kak_cursor_line:$kak_cursor_column:$kak_cursor_byte_offset:$PWD:$kak_timestamp:$kak_buffile:$kak_client:$kak_session > $kak_opt_jedi_dir/fifo
        }
    }

    def jedi-enable-autocomplete %{
        set window completers "option=jedi_completions:filename"

        hook window -group jedi-autocomplete InsertChar \. %{
            jedi complete
        }

        hook window -group jedi-autocomplete InsertChar '^[ ,]$' %{
            try %{
                exec -draft '<esc><a-x><a-k>(import|from)<ret>'
                jedi complete
            }
        }

        hook window -group jedi-autocomplete InsertChar '^[(), ]$' %{
            jedi call_signatures
        }

        hook window -group jedi-autocomplete InsertIdle .* %{
            jedi call_signatures
        }

        map window insert <c-x> '<a-;>:jedi complete<ret>'
        map window insert <c-s> '<a-;>:jedi call_signatures<ret>'
    }

    def jedi-disable-autocomplete %{
        rmhooks window jedi-autocomplete
    }

    def -hidden -params 2 jedi-docstring %{
        eval -client %arg{1} %{
            eval -try-client %opt{docsclient} %{
                edit! -scratch '*doc*'
                exec |cat<space> %arg{2}<ret>
                exec \%|fmt<space> - %val{window_width} <space> -s <ret>
                exec gg
                set buffer filetype rst
                nop %sh{ rm %arg{2} }
                try %{ rmhl number_lines }
            }
        }
    }
}

