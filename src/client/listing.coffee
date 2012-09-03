a = (link) ->
    "<a href=\"#{link}\">#{link}</a>"

toggle_search_form = (state) ->
    if state
        $("ul#listing").hide()
        $("ul#search").show()
    else
        $("ul#listing").show()
        $("ul#search").hide()

display_search_results = ->
    query = $(this).val()
    if query.length
        toggle_search_form(true)
    else
        toggle_search_form(false)
        return
    
    matches = files.filter (file) ->
        file.path.indexOf(query) isnt -1
    $("ul#search").empty()
    matches.forEach (match) ->
        $("<li class='" + match.type + "'>" + a(match.path) + "</li>").appendTo("ul#search")

$(document).ready ->
    $("ul#search").hide()
    $("input").bind('keyup click', display_search_results)