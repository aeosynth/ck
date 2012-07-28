#[coffeekup](http://github.com/mauricemach/coffeekup) rewrite

doctypes =
  '1.1':          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
  '5':            '<!DOCTYPE html>'
  'basic':        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
  'frameset':     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
  'mobile':       '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
  'strict':       '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'xml':          '<?xml version="1.0" encoding="utf-8" ?>'

tagsNormal = 'a abbr acronym address applet article aside audio b bdo big blockquote body button canvas caption center cite code colgroup command datalist dd del details dfn dir div dl dt em embed fieldset figcaption figure font footer form frameset h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins keygen kbd label legend li map mark menu meter nav noframes noscript object ol optgroup option output p pre progress q rp rt ruby s samp script section select small source span strike strong style sub summary sup table tbody td textarea tfoot th thead time title tr tt u ul var video wbr xmp'.split ' '
tagsSelfClosing = 'area base basefont br col frame hr img input link meta param'.split ' '

html    = null
indent  = null
newline = null

options = {}

nest = (arg) ->
  if typeof arg is 'function'
    indent += ' ' if options.format
    arg = arg.call options.context
    indent = indent.slice 0, -1 if options.format

    # https://github.com/jashkenas/coffee-script/issues/issue/1081
    # `coffee -e 'fn key: val, foo.bar'` throws an error, so we have to
    # wrap up property accessing in a function.
    if arg is undefined
      html += "#{newline}#{indent}"
  switch typeof arg
    when 'string', 'number'
      html += if options.autoescape then scope.esc arg else arg
    when 'object'
      html += arg.html if arg.html?

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

    nest arg for arg in args

    html += "</#{tag}>"

    return

scope =
  coffeescript: (fn) ->
    @script fn.toString().replace 'function () ', ''
    return
  comment: (str) ->
    html += "#{newline}#{indent}<!--#{str}-->"
    return
  doctype: (key=5) ->
    html += "#{indent}#{doctypes[key]}"
    return
  esc: (str) ->
    str.replace /[&<>"']/g, (c) ->
      switch c
        when '&' then '&amp;'
        when '<' then '&lt;'
        when '>' then '&gt;'
        when '"' then '&quot;'
        when "'" then '&#39;'
  ie: (expr, arg) ->
    html += "#{newline}#{indent}<!--[if #{expr}]>"
    nest arg
    html += "<![endif]-->"
    return

for tag in tagsNormal
  compileTag tag, false # don't self close
for tag in tagsSelfClosing
  compileTag tag, true # self close

compileFile = (path) ->
  fs = require 'fs'
  code = fs.readFileSync path, 'utf8'
  compile code

compile = (code) ->
  code =
    if typeof code is 'function'
      code.toString().replace 'function () ', ''
    else
      cs = require 'coffee-script'
      cs.compile code, bare: true
  fn = Function 'scope', "with (scope) { #{code} }"
  (_options) ->
    options = _options
    html    = ''
    indent  = ''
    newline = if options.format then '\n' else ''
    fn.call options.context, scope
    html

window.ck = {compile, scope, esc: scope.esc}
