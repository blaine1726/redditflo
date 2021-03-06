React = require('react')
reddit = require('redditflo/reddit')
_ = require('underscore')
{Feed} = require('redditflo/feed')
Python = require('redditflo/python')
{Loading} = require('redditflo/loading')

User = React.createClass
  setAuthor: ->
    @props.setUser @props.user.name
    @props.hide()

  render: ->
    {div} = React.DOM
    div
      className: 'user-sort-item'
      onClick: => @setAuthor()
      "@#{@props.user.name}"

Homepage = React.createClass
  getInitialState: ->
    start: 0
    loading: yes
    users: no
    search: ''
    userFilter: ''

  onClickPrevious: ->
    start = Math.max 0, @state.start-@props.nShown
    @setState start: start
    window.scroll(window.scrollX, 0)

  onClickNext: ->
    n = @props.feed.filter(=> (not @props.authorFilter?) or (feed.data.data is @props.authorFilter)).length
    start = Math.min n-@props.nShown, @state.start+@props.nShown
    @setState start: start
    window.scroll(window.scrollX, 0)

  renderNavigation: ->
    {div, button} = React.DOM
    div className: 'nav-buttons',
      button
        className: 'nav-button left'
        onClick: @onClickPrevious
        style:
          float: 'left'
        'Previous'
      button
        className: 'nav-button right'
        onClick: @onClickNext
        style:
          float: 'right'
        'Next'

  handleSort: (sort) ->
    @props.setSort sort

  notLoading: -> @setState loading: no

  handleUserSort: (e) ->
    e.stopPropagation()
    @setState search: ''
    @setState users: not @state.users
    #@handleSort 'author'

  setSearch: (e) -> @setState search: e.target.value

  hide: ->
    @setState search: ''
    @setState users: no

  render: ->
    {button, div, img, span, webview, input} = React.DOM
    feed = @props.feed
    start = @state.start
    end = start + @props.nShown
    div {},
      if @state.loading
        React.createElement(Loading, {})
      div
        className: 'container'
        onClick: => @hide()
        div className: 'sort-buttons',
            span className: 'sort-by', 'Sort By:'
            button
              className: "sort-button #{'focus' if @props.focus is 'created_utc'}"
              onClick: => @handleSort 'created_utc'
              'time'
            button
              className:  "sort-button #{'focus' if @props.focus is 'score'}"
              onClick: => @handleSort 'score'
              'score'
            button
              className: "sort-button #{'focus' if @props.focus is 'ups'}"
              onClick: => @handleSort 'ups'
              'ups'
            button
              className: "sort-button #{'focus' if @props.focus is 'downs'}"
              onClick: => @handleSort 'downs'
              'downs'
            button
              className: "sort-button #{'focus' if @state.userFilter isnt '' or @props.focus is 'author'}"
              onClick: (e) => @handleUserSort e
              'author'
        if @state.users
          div
            className: 'user-sort'
            onClick: (e) => e.stopPropagation()
            div className: 'static-items',
              div
                className: 'user-sort-item'
                onClick: => @setState userFilter: ''
                'All'
              input
                className: 'user-sort-input'
                placeholder: 'Search'
                onChange: (e) => @setSearch e
            div className: 'dynamic-items',
              @props.users.map (user) =>
                params =
                  user: user
                  setUser: (val) =>
                    @setState start: 0
                    @setState userFilter: val
                  hide: @hide
                React.createElement(User, params) if user.name[...@state.search.length] is @state.search
        feed.filter (feed) => (@state.userFilter is '' or feed.data.author is @state.userFilter)
          .slice(start, end).map (data) =>
            span key: data.data.name,
              React.createElement Feed,
                data: data
                notLoading: @notLoading
        if feed.length > 0
          @renderNavigation()

module.exports =
  Homepage: Homepage
