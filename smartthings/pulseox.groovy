/**
 * SPO2 & Heart Rate Sensor (Connect)
 *
 *  Author: SmartThings
 *  Date: 2013-12-10
 */

// Automatically generated. Make future change here.
definition(
    name: "SPO2 & Heart Rate Sensor (Connect)",
    namespace: "smartthings",
    author: "juano23@gmail.com",
    description: "Enables end point to update SPO2 & Heart Rate Sensor",
    category: "Convenience",
    iconUrl: "https://s3.amazonaws.com/smartapp-icons/Partner/sonos.png",
    iconX2Url: "https://s3.amazonaws.com/smartapp-icons/Partner/sonos@2x.png",
    oauth: true
)

preferences {
	section {
		input "spo2bpm", "capability.actuator", title: "SPO2 & Heart Rate Sensor", required: true
	}
}

mappings {
    path("/bpm/:value") { action: [ POST: "bpm", GET: "bpm"] }
    path("/spo2/:value") { action: [ POST: "spo2", GET: "spo2"] }
}

def installed() {
	log.debug "Installed with settings: ${settings}"
    initialize()
}

def updated() {
	log.debug "Updated with settings: ${settings}"
	unsubscribe()
	initialize()
}

def initialize() {
	createAccessToken()
	def hookUrl = "https://graph.api.smartthings.com/api/token/${state.accessToken}/smartapps/installations/${app.id}/spo2/"
    log.debug "Callback URL: $hookUrl"
}


def bpm() {
    log.debug "BPM: $params.value"
    spo2bpm.setbpm(params.value)
    return [status:"OK"]
}

def spo2() {
    log.debug "SPO2: $params.value"
    spo2bpm.setspo2(params.value)
    return [status:"OK"]
}

