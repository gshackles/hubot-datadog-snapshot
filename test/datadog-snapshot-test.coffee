process.env.HUBOT_DATADOG_GRAPH_RESPONSE_DELAY = 0

Helper = require('hubot-test-helper')
helper = new Helper('../src/datadog-snapshot.coffee')
expect = require('chai').expect
sinon = require('sinon')

_expectMessages = (room, messages, done) ->
  setTimeout ( ->
    expect(room.messages).to.eql(messages)
    done()
  ), 100
  
_setSavedQueries = (room, queries) ->
  room.robot.brain.data._private =
    datadog_savedqueries: queries
  room.robot.brain.emit 'loaded'

describe 'datadog-snapshot', ->
  graphUrl = 'http://datadog.url/awesome-graph'
  
  room = null
  dogapi = null
  dogapiNowStub = null
  dogapiSnapshotStub = null
  
  beforeEach ->
    dogapi = require 'dogapi'
    dogapiNowStub = sinon.stub dogapi, 'now', () -> 1455475648
    dogapiSnapshotStub = sinon.stub dogapi.graph, 'snapshot'
    dogapiSnapshotStub.yields null,
      snapshot_url: graphUrl
    
    room = helper.createRoom()
    _setSavedQueries room, null
  
  afterEach ->
    dogapi.now.restore()
    dogapi.graph.snapshot.restore()
    
    room.destroy()

  context 'list command', ->
    it 'handles when there are no saved queries', (done) ->
      room.user.say 'greg', 'hubot datadog list'
      
      _expectMessages room, [
          ['greg', 'hubot datadog list']
          ['hubot', 'I don\'t have any saved queries :disappointed:']
        ], done
        
    it 'allows shorthand usage', (done) ->
      room.user.say 'greg', 'hubot dd list'
      
      _expectMessages room, [
          ['greg', 'hubot dd list']
          ['hubot', 'I don\'t have any saved queries :disappointed:']
        ], done
        
    it 'lists a single saved query', (done) ->
      _setSavedQueries room,
        cpu: 'cpu query'
        
      room.user.say 'greg', 'hubot datadog list'
      
      _expectMessages room, [
          ['greg', 'hubot datadog list']
          ['hubot', 'I have the following saved queries :sparkles:\n\ncpu']
        ], done
        
    it 'lists multiple saved queries in order', (done) ->
      _setSavedQueries room,
        db: 'db query'
        cpu: 'cpu query'
      
      room.user.say 'greg', 'hubot datadog list'
      
      _expectMessages room, [
          ['greg', 'hubot datadog list']
          ['hubot', 'I have the following saved queries :sparkles:\n\ncpu\ndb']
        ], done
        
  context 'describe command', ->
    it 'handles when there is no matching query', (done) ->
      room.user.say 'greg', 'hubot datadog describe cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog describe cpu']
          ['hubot', '@greg I don\'t know about a query named `cpu` :confused:']
        ], done
        
    it 'allows shorthand usage', (done) ->
      room.user.say 'greg', 'hubot dd describe cpu'
      
      _expectMessages room, [
          ['greg', 'hubot dd describe cpu']
          ['hubot', '@greg I don\'t know about a query named `cpu` :confused:']
        ], done
        
    it 'responds with the definition for a saved query', (done) ->
      _setSavedQueries room,
        cpu: 'cpu query'
        
      room.user.say 'greg', 'hubot dd describe cpu'
      
      _expectMessages room, [
          ['greg', 'hubot dd describe cpu']
          ['hubot', '@greg That query is defined as `cpu query`']
        ], done
        
  context 'delete command', ->
    it 'handles when there is no matching query', (done) ->
      room.user.say 'greg', 'hubot datadog delete cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog delete cpu']
          ['hubot', '@greg I don\'t know about a query named `cpu` :confused:']
        ], done
        
    it 'allows shorthand usage', (done) ->
      room.user.say 'greg', 'hubot dd delete cpu'
      
      _expectMessages room, [
          ['greg', 'hubot dd delete cpu']
          ['hubot', '@greg I don\'t know about a query named `cpu` :confused:']
        ], done
        
    it 'deletes a saved query', (done) ->
      _setSavedQueries room,
        cpu: 'cpu query'
        
      room.user.say 'greg', 'hubot datadog delete cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog delete cpu']
          ['hubot', '@greg I deleted the query `cpu`']
        ], done
        
  context 'query command', ->
    it 'searches for query when there is no matching saved query', (done) ->
      room.user.say 'greg', 'hubot datadog query cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog query cpu']
          ['hubot', graphUrl]
        ], () ->
          expect(dogapiSnapshotStub.calledWith('cpu')).to.eql(true)
          
          done()
          
    it 'allows shorthand usage', (done) ->
      room.user.say 'greg', 'hubot dd query cpu'
      
      _expectMessages room, [
          ['greg', 'hubot dd query cpu']
          ['hubot', graphUrl]
        ], () ->
          expect(dogapiSnapshotStub.calledWith('cpu')).to.eql(true)
          
          done()
        
    it 'searches for saved query when one matches', (done) ->
      _setSavedQueries room,
        cpu: 'cpu query'
      
      room.user.say 'greg', 'hubot datadog query cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog query cpu']
          ['hubot', graphUrl]
        ], () ->
          expect(dogapiSnapshotStub.calledWith('cpu query')).to.eql(true)
          
          done()
    
  context 'save command', ->
    it 'handles when there is no query to save', (done) ->
      room.user.say 'greg', 'hubot datadog save that as cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog save that as cpu']
          ['hubot', '@greg I don\'t have any queries to save for you :confused:']
        ], done
        
    it 'allows \'save as\' shorthand', (done) ->
      room.user.say 'greg', 'hubot datadog save as cpu'
      
      _expectMessages room, [
          ['greg', 'hubot datadog save as cpu']
          ['hubot', '@greg I don\'t have any queries to save for you :confused:']
        ], done
        
    it 'allows \'dd\' shorthand', (done) ->
      room.user.say 'greg', 'hubot dd save as cpu'
      
      _expectMessages room, [
          ['greg', 'hubot dd save as cpu']
          ['hubot', '@greg I don\'t have any queries to save for you :confused:']
        ], done