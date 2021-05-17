package de.qaware.oss.cloud.service.process.boundary;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import de.qaware.oss.cloud.service.process.domain.ProcessEvent;
import io.opentracing.Tracer;
import io.opentracing.contrib.jms.common.TracingMessageListener;
import org.keycloak.representations.IDToken;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.enterprise.event.Event;
import javax.inject.Inject;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;
import javax.json.Json;
import javax.json.JsonReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.logging.Level;
import java.util.logging.Logger;

@MessageDriven(name = "ProcessEventMDB", activationConfig = {
        @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "jms/ProcessEvents"),
        @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge"),
        @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Topic"),
        @ActivationConfigProperty(propertyName = "destination", propertyValue = "PROCESS.EVENTS"),
        @ActivationConfigProperty(propertyName = "resourceAdapter", propertyValue = "activemq-rar"),
        @ActivationConfigProperty(propertyName = "subscriptionDurability", propertyValue = "Durable"),
        @ActivationConfigProperty(propertyName = "clientId", propertyValue = "process-service"),
        @ActivationConfigProperty(propertyName = "subscriptionName", propertyValue = "ProcessEventMDB"),
        @ActivationConfigProperty(propertyName = "messageSelector",
                propertyValue = "contentType = 'application/vnd.process.v1+json'")
})
public class ProcessEventMDB implements MessageListener {

    @Inject
    private Logger logger;

    @Inject
    private Event<ProcessEvent> processEvent;

    @Inject
    private Tracer tracer;

    @Override
    public void onMessage(Message message) {
        logger.log(Level.INFO, "Received inbound process event message {0}.", message);

        new TracingMessageListener(this::onTracedMessage, tracer).onMessage(message);
    }

    private String getBody(Message message) {
        String body = null;
        try {
            if (message instanceof TextMessage) {
                body = ((TextMessage) message).getText();
            }
        } catch (JMSException e) {
            logger.log(Level.WARNING, "Could not get message body.", e);
        }
        return body;
    }

    private IDToken getIDToken(Message message) {

        IDToken idToken = null;
        ObjectMapper objectMapper = new ObjectMapper();

        if (message instanceof TextMessage) {
            try {
                idToken = objectMapper.readValue(message.getStringProperty("idToken"), IDToken.class);
            } catch (JMSException e) {
                logger.log(Level.WARNING, "Could not get message body.", e);
            } catch (JsonMappingException e) {
                logger.log(Level.WARNING, "Could not map json.", e);
            } catch (JsonParseException e) {
                logger.log(Level.WARNING, "Could not parse json.", e);
            } catch (IOException e) {
                logger.log(Level.WARNING, "Could not interact with IO.", e);
            }
        }

        return idToken;
    }

    private String getEventType(Message message) {
        String eventType = null;
        try {
            eventType = message.getJMSType();
        } catch (JMSException e) {
            logger.log(Level.WARNING, "Could not get JMS type.", e);
        }
        return eventType;
    }

    private void onTracedMessage(Message m) {
        String eventType = getEventType(m);
        String body = getBody(m);
        IDToken idToken = getIDToken(m);

        if ((eventType != null) && (body != null) && (idToken != null)) {
            try (JsonReader reader = Json.createReader(new StringReader(body))) {
                processEvent.fire(ProcessEvent.from(eventType, reader.readObject(), idToken));
            }
        }
    }
}
