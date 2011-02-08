#[coffeekup](http://github.com/mauricemach/coffeekup) rewrite

cs = require 'coffee-script'
fs = require 'fs'

doctypes =
  '5': '<!DOCTYPE html>'
  'xml': '<?xml version="1.0" encoding="utf-8" ?>'
  'default': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
  '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
  'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
  'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'

tagsNormal = 'a abbr acronym address applet article aside audio b bdo big blockquote body button canvas caption center cite code colgroup command datalist dd del details dfn dir div dl dt em embed fieldset figcaption figure font footer form frameset h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins keygen kbd label legend li map mark menu meter nav noframes noscript object ol optgroup option output p pre progress q rp rt ruby s samp script section select small source span strike strong style sub summary sup table tbody td textarea tfoot th thead time title tr tt u ul var video wbr xmp'.split ' '
tagsSelfClosing = 'area base basefont br col frame hr img input link meta param'.split ' '

html = ''
indent = ''

scope =
  comment: (str) ->
    html += "#{indent}<!--#{str}-->\n"
  doctype: (key=5) ->
    html += "#{indent}#{doctypes[key]}\n"
  esc: (str) ->
    str.replace /</g, '&lt;'

compileTag = (tag, selfClosing) ->
  scope[tag] = (args...) ->
    html += "#{indent}<#{tag}"

    if typeof args[0] is 'object'
      for key, val of args.shift()
        if typeof val is 'boolean'
          html += " #{key}" if val is true
        else
          html += " #{key}=\"#{val}\""

    html += ">\n"

    return if selfClosing

    indent += ' '
    for arg in args
      if typeof arg is 'function'
        ret = arg.call scope.thisArg
        if typeof ret is 'string'
          html += indent + ret + '\n'
      else
        html += indent + arg + '\n'
    indent = indent.slice 0, -1

    html += "#{indent}</#{tag}>\n"

    return

for tag in tagsNormal
  compileTag tag, false # don't self close
for tag in tagsSelfClosing
  compileTag tag, true # self close

@compile = (path) ->
  code = fs.readFileSync path, 'utf8'
  @compileString code
@compileString = (code) ->
  code = cs.compile code, bare: true
  code = "with (scope) { #{code} }"
  Function 'scope', code
@render = (fn, thisArg) ->
  scope.thisArg = thisArg
  fn.call thisArg, scope
  [ret, html] = [html, '']
  ret
