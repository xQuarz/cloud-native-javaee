package de.qaware.oss.cloud.service.process.domain;

import lombok.Data;
import org.keycloak.representations.IDToken;

import javax.json.JsonObject;

@Data
public class ProcessEvent {

    public enum EventType {
        ProcessCreated, BillingInitiated, PaymentReceived
    }

    private final String processId;
    private final EventType eventType;
    private final JsonObject payload;
    private final IDToken idToken;

    private ProcessEvent(EventType eventType, JsonObject payload, IDToken idToken) {
        this.processId = payload.getString("processId");
        this.eventType = eventType;
        this.payload = payload;
        this.idToken = idToken;
    }

    public static ProcessEvent created(JsonObject payload, IDToken idToken) {
        return new ProcessEvent(EventType.ProcessCreated, payload, idToken);
    }

    public static ProcessEvent from(String eventTypeValue, JsonObject payload, IDToken idToken) {
        EventType eventType = EventType.valueOf(eventTypeValue);
        return new ProcessEvent(eventType, payload, idToken);
    }
}
