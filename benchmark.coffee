ck = require './lib/ck'
coffeekup = require 'coffeekup'

template = ->
  doctype 5
  html ->
    head ->
      title @title
    body ->
      div id: 'content', ->
        for post in @posts
          div class: 'post', ->
            p post.name
            div post.comment
      form method: 'post', ->
        ul ->
          li -> input name: 'name'
          li -> textarea name: 'comment'
          li -> input type: 'submit'

context =
  title: 'my first website!'
  posts: []

ck_template = ck.compile template
coffeekup_template = coffeekup.compile template

benchmark = (name, fn) ->
  start = new Date
  for i in [0..10000]
    fn()
  end = new Date
  console.log "#{name}: #{end - start}ms"

exports =
  benchmark 'ck', -> ck_template context: context
  benchmark 'ck (format)', -> ck_template context: context, format: true
  benchmark 'coffeekup', -> coffeekup_template context: context
  benchmark 'coffeekup (format)', -> coffeekup_template context: context, format: true
