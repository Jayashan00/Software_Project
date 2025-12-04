package com.smart_wastebackend.repository;

import com.smart_wastebackend.model.TruckAssignment;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TruckAssignmentRepository extends MongoRepository<TruckAssignment, String> {

    Optional<TruckAssignment> findTopByTruckIdOrderByAssignedDateDesc(String truckId);

    // --- ADD THESE METHODS ---
    boolean existsByTruckId(String truckId);

    Optional<TruckAssignment> findByCollectorId(String collectorId);
    // --- END ---
}