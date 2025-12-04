package com.smart_wastebackend.model;

import com.smart_wastebackend.enums.TruckStatusEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDate;

@Document(collection = "truck_inventory")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TruckInventory {

    @Id
    private String id;

    @Indexed(unique = true)
    @Field("registration_number")
    private String registrationNumber;

    @Field("capacity_kg")
    private Long capacityKg;

    @Field("last_maintenance")
    private LocalDate lastMaintenance;

    @Field("status")
    private TruckStatusEnum status;

    // ✅ ADDED: GPS Coordinates for Tracking
    @Field("latitude")
    private Double latitude;

    @Field("longitude")
    private Double longitude;
}