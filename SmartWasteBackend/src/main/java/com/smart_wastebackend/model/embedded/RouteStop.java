package com.smart_wastebackend.model.embedded;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RouteStop {

    private String binId;

    private Long stopOrder;

    private Double latitude;

    private Double longitude;
}