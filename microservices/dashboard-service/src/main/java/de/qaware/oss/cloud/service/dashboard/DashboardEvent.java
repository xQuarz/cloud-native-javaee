package de.qaware.oss.cloud.service.dashboard;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import org.keycloak.representations.IDToken;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import java.io.IOException;
import java.io.StringReader;

@Data
public class DashboardEvent {

    private final String destination;
    private final String eventType;
    private final JsonObject payload;
    private final IDToken idToken;

    public DashboardEvent(String destination, String eventType, JsonObject payload) {
        this.destination = destination;
        this.eventType = eventType;
        this.payload = payload;
        this.idToken = getIDToken(payload);
    }

    public IDToken getIDToken(JsonObject payload) {

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

    /**
     * Return the JSON representation of this event.
     *
     * @return the JSON representation
     */
    public JsonObject toJson() {
        return Json.createObjectBuilder()
                .add("destination", getDestination())
                .add("eventType", getEventType())
                .add("payload", getPayload())
                .build();
    }
}
