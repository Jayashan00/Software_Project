package com.smart_wastebackend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smart_wastebackend.dto.BinStatusDTO;
import com.smart_wastebackend.exception.BinStatusNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHandler;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;

@Service
@Slf4j
public class MqttMessageListener {

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private BinStatusService binStatusService;

    @Autowired
    private BinStatusSocketService binStatusSocketService;

    @Value("${mqtt.client-id}")
    private String clientId;

    @Value("${mqtt.status-topic}")
    private String statusTopic;

    @Value("${mqtt.location-topic}")
    private String locationTopic;

    /** Create inbound channel for MQTT messages */
    @Bean
    public DirectChannel mqttInboundChannel() {
        return new DirectChannel();
    }

    /** Subscribe to topics from the broker */
    @Bean
    public MessageProducer inbound(
            MqttPahoClientFactory clientFactory,
            DirectChannel mqttInboundChannel // <-- FIX #1: Inject the channel bean
    ) {
        MqttPahoMessageDrivenChannelAdapter adapter = new MqttPahoMessageDrivenChannelAdapter(
                clientId + "_listener",
                clientFactory,
                statusTopic,
                locationTopic
        );

        adapter.setCompletionTimeout(5000);
        adapter.setQos(1);

        adapter.setOutputChannel(mqttInboundChannel); // <-- FIX #2: Use the injected bean

        log.info("MQTT inbound adapter initialized for topics: {}, {}", statusTopic, locationTopic);

        return adapter;
    }

    /** Handle incoming MQTT messages */
    @Bean
    @ServiceActivator(inputChannel = "mqttInboundChannel")
    public MessageHandler handleMessage() {
        return (Message<?> message) -> {
            String topic = message.getHeaders().get("mqtt_receivedTopic").toString();
            String payload = (message.getPayload() instanceof byte[])
                    ? new String((byte[]) message.getPayload(), StandardCharsets.UTF_8)
                    : message.getPayload().toString();

            log.info("MQTT Message Received - Topic: {}, Payload: {}", topic, payload);

            try {
                if (topic.matches(statusTopic.replace("+", "[^/]+"))) {
                    handleStatusMessage(topic, payload);
                } else if (topic.matches(locationTopic.replace("+", "[^/]+"))) {
                    handleLocationMessage(topic, payload);
                }
            } catch (Exception e) {
                log.error("Error processing MQTT message from topic '{}': {}", topic, e.getMessage(), e);
            }
        };
    }

    /** Process bin status JSON messages */
    private void handleStatusMessage(String topic, String payload) {
        try {
            String binId = extractBinIdFromTopic(topic);
            BinStatusDTO statusDto = objectMapper.readValue(payload, BinStatusDTO.class);
            statusDto.setBinId(binId);

            binStatusService.updateBinLevels(statusDto);
            binStatusSocketService.sendBinStatusToUser(binId, statusDto);

            log.info("Processed bin status for ID: {}", binId);
        } catch (IllegalArgumentException | JsonProcessingException | BinStatusNotFoundException e) {
            log.warn("Failed to process status message for topic '{}'. Error: {}", topic, e.getMessage());
        }
    }

    /** Process bin location messages */
    private void handleLocationMessage(String topic, String payload) {
        String binId = extractBinIdFromTopic(topic);
        log.info("Received location for bin {}: {}", binId, payload);
        // TODO: Parse and save GPS data if needed
    }

    /** Extract bin ID from MQTT topic (e.g., smartwaste/bin/{binId}/status) */
    private String extractBinIdFromTopic(String topic) {
        String[] parts = topic.split("/");
        if (parts.length >= 3) {
            return parts[2];
        } else {
            throw new IllegalArgumentException("Invalid topic format: " + topic);
        }
    }
}