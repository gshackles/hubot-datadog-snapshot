# Description:
#   Query graph snapshots from Datadog
#
# Configuration:
#   HUBOT_DATADOG_API_KEY
#   HUBOT_DATADOG_APP_KEY
#   HUBOT_DATADOG_GRAPH_RESPONSE_DELAY
#
# Commands:
#   hubot datadog query <#s|m|h|d> <query> - graph the specified query
#   hubot datadog save that as <name> - save the last query
#   hubot datadog delete <name> - remove the specified query
#   hubot datadog describe <name> - describe the saved query
#   hubot datadog list
#
# Author:
#   gshackles

dogapi = require("dogapi")

userGraphs = {}
queryStore = null
saveQueryStore = null
graphResponseDelay = 0

getIntervalSeconds = (input) ->
  input = (input or "60m").trim()
  multiplier = switch input.substring input.length - 1
    when "s" then 1
    when "m" then 60
    when "h" then 3600
    when "d" then 86400
  value = +(input.substring 0, input.length - 1)

  return multiplier * value

getSnapshotUrl = (query, interval, callback) ->
  to = dogapi.now()
  from = to - (getIntervalSeconds interval)

  dogapi.graph.snapshot query, from, to, (err, response) ->
    if (err)
      callback null
    else
      # it seems the image isn't actually available immediately, so pause briefly before trying to access it
      setTimeout ( -> 
        callback response.snapshot_url
      ), graphResponseDelay

queryCommand = (response) ->
  query = response.match[2]
  
  if queryStore[query]
    query = queryStore[query]
  
  getSnapshotUrl query, response.match[1], (url) ->
    unless url
      response.reply "Sorry, there was a problem fetching that query :crying_cat_face:"
      return

    userGraphs[response.envelope.user.id] = query

    response.send url

saveCommand = (response) ->
  name = response.match[1]
  query = userGraphs[response.envelope.user.id]

  unless query
    response.reply "I don't have any queries to save for you :confused:"
    return

  if queryStore[name]
    response.reply "I already have a saved query named `#{name}`"
    return

  queryStore[name] = query
  do saveQueryStore
  response.reply "I saved that graph for you as `#{name}`"

listCommand = (response) ->
  savedNames = Object.keys(queryStore)
  savedNames.sort()
  
  if savedNames.length > 0
    response.send "I have the following saved queries :sparkles:\n\n#{savedNames.join("\n")}"
  else
    response.send "I don't have any saved queries :disappointed:"

deleteCommand = (response) ->
  name = response.match[1]

  if queryStore[name]
    delete queryStore[name]
    do saveQueryStore
    response.reply "I deleted the query `#{name}`"
  else
    response.reply "I don't know about a query named `#{name}` :confused:"

describeCommand = (response) ->
  name = response.match[1]
  query = queryStore[name]

  if query
    response.reply "That query is defined as `#{query}`"
  else
    response.reply "I don't know about a query named `#{name}` :confused:"

module.exports = (robot) ->
  options =
    api_key: process.env.HUBOT_DATADOG_API_KEY
    app_key: process.env.HUBOT_DATADOG_APP_KEY

  dogapi.initialize options
  
  graphResponseDelay = process.env.HUBOT_DATADOG_GRAPH_RESPONSE_DELAY or 2000

  robot.brain.on 'loaded', () ->
    userGraphs = {}
    queryStore = robot.brain.get("datadog_savedqueries") or {}

  saveQueryStore = () -> robot.brain.set "datadog_savedqueries", queryStore

  robot.respond /(?:datadog|dd)\s+query(?:\s+me)?\s+(\d+[smhd]\s+)?(.*)/i, queryCommand
  robot.respond /(?:datadog|dd)\s+save(?:\s+that)?\s+as\s+(.*)/i, saveCommand
  robot.respond /(?:datadog|dd)\s+list/i, listCommand
  robot.respond /(?:datadog|dd)\s+delete\s+(.*)/i, deleteCommand
  robot.respond /(?:datadog|dd)\s+describe\s+(.*)/i, describeCommand