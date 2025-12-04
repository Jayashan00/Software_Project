package com.smart_wastebackend.dto;

import com.smart_wastebackend.enums.TruckStatusEnum;

public class ChangeTruckStatusRequestDTO {
    private TruckStatusEnum status;

    public TruckStatusEnum getStatus() {
        return status;
    }

    public void setStatus(TruckStatusEnum status) {
        this.status = status;
    }
}
