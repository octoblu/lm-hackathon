class Device
  constructor: (@meshblu, options={}) ->

  onMessage: (callback=->) =>
    @meshblu.onMessage callback

module.exports = Device
