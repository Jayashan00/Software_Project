package com.smart_wastebackend.repository;

import com.smart_wastebackend.enums.RouteStatusEnum;
import com.smart_wastebackend.model.Route;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RouteRepository extends MongoRepository<Route, String> {

    Optional<Route> findFirstByAssignedToIdAndStatusOrderByDateCreatedDesc(String assignedToId, RouteStatusEnum status);

    Optional<Route> findById(String routeId);

    // Checks if a Route exists with a specific ID AND a specific binId in its 'stops'
    boolean existsByIdAndStopsBinId(String routeId, String binId);

    // Checks if ANY route contains a stop with the given binId
    boolean existsByStopsBinId(String binId);

    // ✅ ADD THIS MISSING METHOD
    // Finds a route where the 'stops' list contains the given 'binId' AND matches the 'status'
    Optional<Route> findByStopsBinIdAndStatus(String binId, RouteStatusEnum status);
}