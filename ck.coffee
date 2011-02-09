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

context = null
html    = null
indent  = null
newline = null

compileTag = (tag, selfClosing) ->
  scope[tag] = (args...) ->
    html += "#{newline}#{indent}<#{tag}"

    if typeof args[0] is 'object'
      for key, val of args.shift()
        if typeof val is 'boolean'
          html += " #{key}" if val is true
        else
          html += " #{key}=\"#{val}\""

    html += ">"

    return if selfClosing

    for arg in args
      if typeof arg is 'function'
        indent += ' ' if newline
        arg = arg.call context
        indent = indent.slice 0, -1 if newline

        # https://github.com/jashkenas/coffee-script/issues/issue/1081
        # `coffee -e 'fn key: val, foo.bar'` throws an error, so constants
        # passed after implicit objects must be wrapped as a return value
        if arg is undefined
          html += "#{newline}#{indent}"
          continue
      html += arg

    html += "</#{tag}>"

    return

scope =
  comment: (str) ->
    html += "#{newline}#{indent}<!--#{str}-->"
    return
  doctype: (key=5) ->
    html += "#{indent}#{doctypes[key]}"
    return
  esc: (str) ->
    str.replace /</g, '&lt;'

for tag in tagsNormal
  compileTag tag, false # don't self close
for tag in tagsSelfClosing
  compileTag tag, true # self close

@compileFile = (path) ->
  code = fs.readFileSync path, 'utf8'
  @compile code
@compile = (code) ->
  code =
    if typeof code is 'function'
      code.toString().replace 'function () ', ''
    else
      cs.compile code, bare: true
  Function 'scope', "with (scope) { #{code} }"
@render = (fn, options={}) ->
  {context, format} = options
  html    = ''
  indent  = ''
  newline = if format then '\n' else ''
  fn.call context, scope
  html
