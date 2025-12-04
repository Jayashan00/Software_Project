package com.smart_wastebackend.dto;

import com.smart_wastebackend.enums.BinStatusEnum;

public class ChangeBinStatusRequestDTO {
    private BinStatusEnum status;

    public BinStatusEnum getStatus() {
        return status;
    }

    public void setStatus(BinStatusEnum status) {
        this.status = status;
    }
}
