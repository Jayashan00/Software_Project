package com.smart_wastebackend.model;

import com.smart_wastebackend.enums.RouteStatusEnum;
import com.smart_wastebackend.model.embedded.RouteStop;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "routes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Route {

    @Id
    private String id;

    // --- THIS IS THE MISSING FIELD ---
    @Field("name")
    private String name;
    // --- END OF FIX ---

    @Field("assigned_to_id")
    private String assignedToId;

    @Field("date_created")
    private LocalDateTime dateCreated;

    @Field("status")
    private RouteStatusEnum status;

    @Field("route_start_time")
    private LocalDateTime routeStartTime;

    @Field("route_end_time")
    private LocalDateTime routeEndTime;

    @Field("stops")
    private List<RouteStop> stops;
}