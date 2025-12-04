package com.smart_wastebackend.repository;

import com.smart_wastebackend.model.MaintenanceRequests;
import com.smart_wastebackend.enums.MaintenanceStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaintenanceRequestRepository extends MongoRepository<MaintenanceRequests, String> {

    List<MaintenanceRequests> findByBinIdOrderByCreatedAtDesc(String binId);

    List<MaintenanceRequests> findByRequesterIdOrderByCreatedAtDesc(String requesterId);

    List<MaintenanceRequests> findByStatusOrderByCreatedAtDesc(MaintenanceStatus status);
}