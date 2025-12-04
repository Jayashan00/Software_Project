package com.smart_wastebackend.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;

@Document(collection = "truck_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TruckAssignment {

    @Id
    private String id;

    @Field("collector_id")
    private String collectorId;

    @Field("truck_id")
    private String truckId;

    @Field("assigned_date")
    private LocalDateTime assignedDate;
}