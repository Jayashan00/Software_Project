package com.smart_wastebackend.config;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;

/**
 * ✅ This configuration sets up a secure SSL MQTT connection to HiveMQ Cloud.
 */
@Configuration
public class MqttConfig {

    @Value("${mqtt.broker}")
    private String brokerUrl;

    @Value("${mqtt.username}")
    private String username;

    @Value("${mqtt.password}")
    private String password;

    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();

        MqttConnectOptions options = new MqttConnectOptions();
        options.setServerURIs(new String[]{brokerUrl});
        options.setUserName(username);
        options.setPassword(password.toCharArray());
        options.setCleanSession(true);
        options.setAutomaticReconnect(true);
        options.setConnectionTimeout(10);

        // --- SSL FIX for HiveMQ Cloud ---
        if (brokerUrl.startsWith("ssl://")) {
            System.setProperty("javax.net.ssl.trustStoreType", "JKS");
            System.setProperty("com.ibm.ssl.protocol", "TLSv1.2");
        }

        factory.setConnectionOptions(options);
        return factory;
    }
}
