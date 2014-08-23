Device = require '../src/device'

describe 'Device', ->
  describe '-> onMessage', ->
    describe 'when a message comes in', ->
      beforeEach ->
        fakeMeshblu = new FakeMeshblu
        @sut = new Device fakeMeshblu
        @callback = sinon.spy()
        @sut.onMessage @callback
        fakeMeshblu.sendMessage 'blah'

      it 'should call my callback', ->
        expect(@callback).to.have.been.calledWith 'blah'

class FakeMeshblu
  subscribe: (owner_id, callback) =>
    @subscribe.calledWith = _.values arguments
    @subscribe.resolve = callback

  onMessage: (@onMessageCallback) =>

  sendMessage: (message) =>
    @onMessageCallback message
