Meshblu = require './src/meshblu'
Device = require './src/device'
{spawn} = require 'child_process'
_   = require 'lodash'

device_uuid = process.env.DEVICE_UUID
device_token = process.env.DEVICE_TOKEN
payload_only = process.env.PAYLOAD_ONLY
meshblu_uri  = process.env.MESHBLU_URI || 'wss://meshblu.octoblu.com'

JADES_IPHONE_UUID = '2a901861-2af8-11e4-9001-b7f689b1ce71'
JADES_IPHONE_TOKEN = '0po2feq55q4a38frifxyfwkkue42huxr'

ROYS_PHONE_UUID = 'ecbbe3d1-2970-11e4-b860-af35e34d021f'
ROYS_PHONE_TOKEN = '0p0xi0dde59kep14ijbrjcwis7d86w29'

RALLYFIGHTER_UUID = 'c43462d1-1cea-11e4-861d-89322229e557/3c701ab0-2a69-11e4-ba29-b7d9779a4387'

GATEWAY_UUID = 'cfe8372a-7ec1-4517-a6c3-843490c21567'
KIT_GATEWAY_UUID = '9dc9031b-ce6e-40f7-a0d7-3e3aca24471d'

DEFAULT_GEO = {heading: 0, latitude: 0, longitude: 0}
UUIDS = {}
UUIDS[JADES_IPHONE_UUID] = 'jade'
UUIDS[ROYS_PHONE_UUID]   = 'roy'

GEOS = {}

meshblu = new Meshblu device_uuid, device_token, meshblu_uri, =>
  unlock = =>
    sendMessage 'unlock'
    sendMessage 'headlightson'
    sendAlljoyn 'Unlocked the car'
    sendLifx()
    sendBlinkyTape()

  lock = =>
    sendMessage 'lock'
    sendAlljoyn 'Locked the car'
    turnOffLifex()
    turnOffBlinkyTape()

  sendMessage = (m) =>
    msg =
      devices : RALLYFIGHTER_UUID
      payload: 
        m: m
    console.log msg
    meshblu.connection.message msg

  sendAlljoyn = (m) =>
    msg =
      devices: GATEWAY_UUID,
      subdevice: "alljoyn",
      payload: 
          method:"notify",
          message: m
    console.log msg
    meshblu.connection.message msg

  turnOffBlinkyTape = =>
    msg =
      devices: KIT_GATEWAY_UUID,
      subdevice: "blinky-tape",
      payload: 's0' 
    console.log msg
    meshblu.connection.message msg

  sendBlinkyTape = =>
    msg =
      devices: KIT_GATEWAY_UUID,
      subdevice: "blinky-tape",
      payload: 'k9' 
    console.log msg
    meshblu.connection.message msg

  turnOffLifex = =>
    msg =
      devices: GATEWAY_UUID
      subdevice: 'lifx'
      payload:
        setState:
          on: false
    console.log msg
    meshblu.connection.message msg

  sendLifx = (m) =>
    setTimeout =>
      msg =
        devices: GATEWAY_UUID
        subdevice: 'lifx'
        payload:
          setState:
            on: true
      console.log msg
      meshblu.connection.message msg
    , 1500

    setTimeout =>
      msg =
        devices: GATEWAY_UUID
        subdevice: 'lifx'
        payload:
          setState:
            hue: 0x1111
            sat: 0xffff
            white: 5000
            lum: 0x8000

      console.log msg
      meshblu.connection.message msg
    , 2000

  lock()

  device = new Device meshblu
  device.onMessage (message) =>
    key = UUIDS[message.fromUuid] || 'unknown'
    GEOS[key] ?= {}
    geo = GEOS[key]

    coords          = message.payload?.sensorData?.data?.coords
    magneticHeading = message.payload?.sensorData?.data?.magneticHeading

    if coords?
      geo.latitude  = coords.latitude
      geo.longitude = coords.longitude

    if magneticHeading?
      geo.heading = magneticHeading
      if geo.heading > 10 and geo.heading < 60
        unlock()
        setTimeout(process.exit, 3000)

    _.each GEOS, (values, name) =>
      console.log name, JSON.stringify(values)

  meshblu.connection.subscribe
    uuid: JADES_IPHONE_UUID,
    token: JADES_IPHONE_TOKEN

  meshblu.connection.subscribe
    uuid: ROYS_PHONE_UUID
    token: ROYS_PHONE_TOKEN
