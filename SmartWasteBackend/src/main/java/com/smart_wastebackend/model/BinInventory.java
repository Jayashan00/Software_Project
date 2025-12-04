package com.smart_wastebackend.model;

import com.smart_wastebackend.enums.BinStatusEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "bin_inventory")
public class
BinInventory {

    @Id
    private String binId;

    @Field("status")
    private BinStatusEnum status;

    @Field("owner_id")
    private String ownerId;

    @Field("assigned_date")
    private LocalDate assignedDate;

    @Field("latitude")
    private Double latitude;

    @Field("longitude")
    private Double longitude;

    // --- Fields from BinStatus are now embedded ---
    @Field("plastic_level")
    private Long plasticLevel;

    @Field("paper_level")
    private Long paperLevel;

    @Field("glass_level")
    private Long glassLevel;

    @Field("last_emptied_at")
    private LocalDateTime lastEmptiedAt;
    // ---------------------------------------------

    public void assignToOwner(String newOwnerId) {
        this.ownerId = newOwnerId;
        this.status = BinStatusEnum.ASSIGNED;
        this.assignedDate = LocalDate.now();
    }
}