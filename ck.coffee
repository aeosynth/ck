doctypes =
  5: '<!doctype html>'
html = null
scope =
  doctype: (doctype) ->
    html += doctypes[doctype]

compile = (tag, selfClosing) ->
  scope[tag] = (args...) ->
    html += "<#{tag}"
    if typeof args[0] is 'object'
      for key, val of args.shift()
        if typeof val is 'boolean'
          html += " #{key}" if val
        else
          html += " #{key}='#{val}'"
    html += ">"

    return if selfClosing

    for arg in args
      if typeof arg is 'function'
        arg()
      else
        html += arg

    html += "</#{tag}>"

for tag in 'body form head html input title'.split ' '
  compile tag
for tag in 'img input'.split ' '
  compile tag, true #selfClosing

@render = (template) ->
  html = ''
  code = template.toString().replace 'function () ', ''
  Function('scope', "with (scope) #{code}") scope
