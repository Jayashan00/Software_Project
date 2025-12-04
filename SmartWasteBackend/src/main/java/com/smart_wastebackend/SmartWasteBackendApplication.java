package com.smart_wastebackend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class SmartWasteBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(SmartWasteBackendApplication.class, args);
	}
}

