package com.smart_wastebackend.model;

import com.smart_wastebackend.enums.MaintenanceStatusEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Document(collection = "maintenance_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MaintenanceRequest {

    @Id
    private String id;

    @Field("user_id")
    private String userId;

    @Field("bin_id")
    private String binId;

    @Field("sorting_malfunction")
    private Boolean sortingMalfunction;

    @Field("bin_status_malfunction")
    private Boolean binStatusMalfunction;

    @Field("gps_malfunction")
    private Boolean gpsMalfunction;

    @Field("description")
    private String description;

    @Field("maintenance_status")
    private MaintenanceStatusEnum maintenanceStatus;
}