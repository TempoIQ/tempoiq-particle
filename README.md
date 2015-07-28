# Particle and TempoIQ

[Particle](https://www.particle.io/) creates wifi- and cell-connected prototyping microcontrollers
and operates a cloud service with most of the primitives needed to setup a simple application with
a web-connected device. We thought it would be interesting to see what it would take to publish
data from a Particle device (in this case, the [Particle Core](http://docs.particle.io/core/)) to
the latest and greatest version of TempoIQ's software. Here, we've created an ambient light sensor.

## Particle Firmware (Wiring)

In the `particle` directory of this project, you'll find the code we're actually running on our core:
`photoResistorPublish.ino`. From here, you can work out how our breadboard is set up. Pin A5 writes
its full voltage into a photoresistor which is connected to a T-junction which feeds directly into A0
and back to ground through a resistor (to attenuate the input into A0). As a result, reading from A0
returns a value which is inversely proportional to the resistance of the photoresistor (or, said
differently, directly proportional to the ambient light at the photoresistor). So `analogRead(A0)`
is how we will measure the ambient light. We then push this value to Particle's api through the
as a simple string using the `Spark.publish` command.

The main loop probably looks unweildy. You might expect that the code could be written more simply
with a call to wiring's `delay()` function. Unfortunately, using "delay" in the main loop along with
`Spark.publish` causes problems when trying to flash the device. Use this method of polling `millis()`
instead.

## `translator.rb`

`translator.rb`, translates from Particle's pub/sub event api into TempoIQ's api. Particle writes
communicates with their cloud via [CoAP](http://coap.technology/) which, as of writing, TempoIQ
does not support as an ingest protocol. However, Particle's cloud service does provide an api which
provides a (Server-Sent Event-based api)[http://docs.particle.io/core/api/#introduction-open-a-stream-of-server-sent-events]
to allow subscribing to events over HTTP. We use [a Server-Sent Event EventMachine library](https://github.com/AF83/em-eventsource)
to get the values out of Particle's cloud service.

The translation script was designed to be run on Heroku, so all of the "secret" values needed by
the script are passed in via environment variables. To use the translator script, you MUST set the
following environment variables:

* TEMPO_HOST (The hostname of your tempoiq service)
* TEMPO_USER (The username for the HTTP basic auth used for TempoIQ Ingest)
* TEMPO_PASS (The password/API secret for the HTTP basic auth used for TempoIQ Ingest)
* PARTICLE_AUTH (The access token for your Particle cloud account)
