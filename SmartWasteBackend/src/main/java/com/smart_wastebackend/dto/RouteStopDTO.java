package com.smart_wastebackend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RouteStopDTO {
        // REMOVED: private Long id;
        // REMOVED: private Long routeId;
        private String binId;
        private Long stopOrder;

        private Double latitude;
        private Double longitude;
}