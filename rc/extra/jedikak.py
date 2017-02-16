"""
hook -group jedi-restart buffer BufWritePost .* jedi-restart
"""
import jedi
import sys
import os
import tempfile
from subprocess import Popen,PIPE

def tell_kak(session, msg):
    p=Popen(['kak', '-p', session.rstrip()], stdin=PIPE)
    print(msg)
    p.communicate(msg.encode('utf-8'))

def esc(cs,s):
    for c in cs:
        s=s.replace(c, "\\"+c)
    return s

def format_completer(c):
    return '|'.join(esc('|:',x) for x in (c.name, c.docstring()[:1000], c.name))

def process(dir, action, line, col, byte, pwd, timestamp, buffile, client, session):
    with open(os.path.join(dir,'buf'),'r') as b:
        source = b.read()

    line=int(line)
    col=int(col)
    byte=int(byte)-1

    if action == 'names':
        defs = jedi.names(source, pwd, all_scopes=True)
        for d in defs:
            print(d.name, d.type, d.line)
        return

    script = jedi.Script(source, line, col-1, pwd, source_path=buffile)

    if action == 'usages':
        def c(y,x):
            return str(y)+'.'+str(x)
        descs=[]
        for use in script.usages():
            y=use.line
            x=use.column+1
            descs+=[c(y,x)+','+c(y,x+len(use.name)-1)]
        if not descs:
            return
        desc=':'.join(descs)+'@'+buffile+'%'+timestamp
        tell_kak(session, 'set-register j '+desc)
        tell_kak(session, 'eval -client '+client+' %{exec %{"jz}}')
        return

    if action == 'docstring':
        docstring=script.goto_definitions()[0].docstring()
        with tempfile.NamedTemporaryFile(
               'w',encoding='utf-8',dir=dir,delete=False) as fd:
            fd.write(docstring)
            tell_kak(session, ' '.join(('jedi-docstring',client,fd.name)))
        return

    if action == 'goto':
        d=script.goto_definitions()[0]
        msg=' '.join(('eval -client',client,
                      'edit', d.module_path, str(d.line), str(d.column+1)))
        tell_kak(session,msg)
        return

    if action == 'call_signatures':
        for cs in script.call_signatures():
            params=[p.name for p in cs.params]
            if cs.index is not None:
                params[cs.index]='*'+params[cs.index]+'*'
            msg='(' + ','.join(params) + ')'
            y,x=cs.bracket_start
            info='info -anchor '+str(y)+'.'+str(x+1)+\
                 ' -placement above %{' + msg + '}'
            """
            info=info+'''
            hook -group once buffer InsertCompletionHide .* %{
                rmhooks buffer once
            ''' + info + '''
            }
            hook -group once buffer InsertCompletionShow .* %{
                rmhooks buffer once
            }
            '''
            """
            tell_kak(session, "eval -client "+client+' %{'+info+'}')
        return

    # other actions: make cursors at all usages of a variable

    msgs=[]

    jcs = script.completions()

    if source[byte].isspace():
        def prev(s):
            return s == source[byte-len(s):byte]
        if prev('import') or prev('from'):
            pass
        else:
            jcs=[]

    if jcs:
        offset = len(jcs[0].name) - len(jcs[0].complete)

        compl=str(line)+'.'+str(col-offset)+'@'+timestamp+':'

        print(compl+' '+str(len(jcs))+' completions.')

        compl+=':'.join(map(format_completer, jcs))
        compl=esc("'",compl)

        msgs=["set buffer="+buffile+" jedi_completions '"+compl+"'"]+msgs

    if msgs:
        tell_kak(session, '\n'.join(msgs)+'\n')

def main(dir):
    print(dir, os.getpid())
    while True:
        sys.stdout.flush()
        with open(os.path.join(dir,'fifo'),'r') as fifo:
            for args in fifo:
                print(args)
                try:
                    process(dir, *args.split(':'))
                except Exception as e:
                    print(e)

if __name__ == '__main__':
    dir=sys.argv[1]
    main(dir)
