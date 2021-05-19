package de.qaware.oss.cloud.service.process.domain;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import org.keycloak.representations.IDToken;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import java.io.IOException;
import java.io.StringReader;

@Data
public class ProcessEvent {

    public enum EventType {
        ProcessCreated, BillingInitiated, PaymentReceived
    }

    private final String processId;
    private final EventType eventType;
    private final JsonObject payload;
    private final IDToken idToken;

    private ProcessEvent(EventType eventType, JsonObject payload) {
        this.processId = payload.getString("processId");
        this.eventType = eventType;
        this.payload = payload;
        this.idToken = getIDToken(payload);
    }

    public static IDToken getIDToken(JsonObject payload) {

        ObjectMapper objectMapper = new ObjectMapper();
        JsonReader reader = Json.createReader(new StringReader(payload.get("idToken").toString()));
        IDToken idToken = null;
        try {
            idToken = objectMapper.readValue(reader.toString(), IDToken.class);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return idToken;
    }

    public static ProcessEvent created(JsonObject payload) {
        return new ProcessEvent(EventType.ProcessCreated, payload);
    }

    public static ProcessEvent from(String eventTypeValue, JsonObject payload) {
        EventType eventType = EventType.valueOf(eventTypeValue);
        return new ProcessEvent(eventType, payload);
    }
}
