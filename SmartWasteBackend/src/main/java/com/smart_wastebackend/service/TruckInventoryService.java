package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.AddTruckRequestDTO;
import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.enums.RouteStatusEnum;
import com.smart_wastebackend.enums.TruckStatusEnum;
import com.smart_wastebackend.exception.TruckNotFoundException;
import com.smart_wastebackend.exception.UserNotFoundException;
import com.smart_wastebackend.model.CollectorProfile;
import com.smart_wastebackend.model.Route;
import com.smart_wastebackend.model.TruckAssignment;
import com.smart_wastebackend.model.TruckInventory;
import com.smart_wastebackend.repository.CollectorProfileRepository;
import com.smart_wastebackend.repository.RouteRepository;
import com.smart_wastebackend.repository.TruckAssignmentRepository;
import com.smart_wastebackend.repository.TruckInventoryRepository;
import jakarta.validation.ValidationException;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class TruckInventoryService {

    private final TruckInventoryRepository truckInventoryRepository;
    private final TruckAssignmentRepository truckAssignmentRepository;
    private final CollectorProfileRepository collectorProfileRepository;
    private final RouteRepository routeRepository;

    @Autowired
    public TruckInventoryService(
            TruckInventoryRepository truckInventoryRepository,
            TruckAssignmentRepository truckAssignmentRepository,
            CollectorProfileRepository collectorProfileRepository,
            RouteRepository routeRepository
    ) {
        this.truckInventoryRepository = truckInventoryRepository;
        this.truckAssignmentRepository = truckAssignmentRepository;
        this.collectorProfileRepository = collectorProfileRepository;
        this.routeRepository = routeRepository;
    }

    // --- STANDARD CRUD METHODS ---

    public ApiResponse<List<TruckInventory>> getTrucksFiltered(TruckStatusEnum status, Long minCapacityKg) {
        List<TruckInventory> trucks;

        if (status != null && minCapacityKg != null) {
            trucks = truckInventoryRepository.findByStatusAndCapacityKgGreaterThanEqual(status, minCapacityKg);
        } else if (status != null) {
            trucks = truckInventoryRepository.findByStatus(status);
        } else if (minCapacityKg != null) {
            trucks = truckInventoryRepository.findByCapacityKgGreaterThanEqual(minCapacityKg);
        } else {
            trucks = truckInventoryRepository.findAll();
        }

        return ApiResponse.<List<TruckInventory>>builder()
                .success(true)
                .message("Trucks fetched successfully")
                .data(trucks)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<TruckInventory> addTruck(String registrationNumber, Long capacityKg) {
        TruckInventory truck = new TruckInventory();
        truck.setRegistrationNumber(registrationNumber);
        truck.setCapacityKg(capacityKg);
        truck.setStatus(TruckStatusEnum.AVAILABLE);

        return ApiResponse.<TruckInventory>builder()
                .success(true)
                .message("Truck added successfully")
                .data(truckInventoryRepository.save(truck))
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<TruckInventory> updateTruck(String truckId, AddTruckRequestDTO request) {
        TruckInventory truck = truckInventoryRepository.findById(truckId)
                .orElseThrow(() -> new TruckNotFoundException("Truck with ID: " + truckId + " not found"));

        truck.setRegistrationNumber(request.getRegistrationNumber());
        truck.setCapacityKg(request.getCapacity());

        TruckInventory updatedTruck = truckInventoryRepository.save(truck);

        return ApiResponse.<TruckInventory>builder()
                .success(true)
                .message("Truck updated successfully")
                .data(updatedTruck)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<Void> deleteTruck(String truckId) {
        TruckInventory truck = truckInventoryRepository.findById(truckId)
                .orElseThrow(() -> new TruckNotFoundException("Truck with ID: " + truckId + " not found"));

        boolean isAssigned = truckAssignmentRepository.existsByTruckId(truckId);

        if (isAssigned) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cannot delete truck: It is currently assigned to a collector.");
        }

        truckInventoryRepository.delete(truck);

        return ApiResponse.<Void>builder()
                .success(true)
                .message("Truck deleted successfully")
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<TruckInventory> changeStatus(String truckId, TruckStatusEnum newStatus) {
        TruckInventory truck = truckInventoryRepository.findById(truckId)
                .orElseThrow(() -> new TruckNotFoundException("Truck with ID: " + truckId + " not found"));

        if (truck.getStatus() == newStatus) {
            return ApiResponse.<TruckInventory>builder()
                    .success(true)
                    .message("Truck is already in the requested status")
                    .data(truck)
                    .timestamp(LocalDateTime.now().toString())
                    .build();
        }

        if (TruckStatusEnum.NEEDS_REPAIR.equals(truck.getStatus()) &&
                TruckStatusEnum.AVAILABLE.equals(newStatus)) {
            truck.setLastMaintenance(LocalDate.now());
        }

        truck.setStatus(newStatus);

        truckInventoryRepository.save(truck);

        return ApiResponse.<TruckInventory>builder()
                .success(true)
                .message("Truck status updated")
                .data(truck)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<TruckInventory> assignTruckToCollector(String truckId, String collectorId) {
        TruckInventory truck = truckInventoryRepository.findById(truckId)
                .orElseThrow(() -> new TruckNotFoundException("Truck with ID " + truckId + " not found"));

        if (truck.getStatus() != TruckStatusEnum.AVAILABLE) {
            throw new ValidationException("Truck is not available for assignment");
        }

        CollectorProfile collector = collectorProfileRepository.findById(collectorId)
                .orElseThrow(() -> new UserNotFoundException("Collector profile not found for user ID: " + collectorId));

        Optional<TruckAssignment> existingAssignment = truckAssignmentRepository.findByCollectorId(collectorId);
        if (existingAssignment.isPresent()) {
            throw new ValidationException("Collector is already assigned to another truck.");
        }

        truck.setStatus(TruckStatusEnum.IN_SERVICE);
        truckInventoryRepository.save(truck);

        TruckAssignment assignment = new TruckAssignment();
        assignment.setTruckId(truck.getId());
        assignment.setCollectorId(collector.getId());
        assignment.setAssignedDate(LocalDateTime.now());
        truckAssignmentRepository.save(assignment);

        return ApiResponse.<TruckInventory>builder()
                .success(true)
                .message("Truck successfully assigned to " + collector.getName())
                .data(truck)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    // --- TRACKING LOGIC ---

    /**
     * Finds the specific truck that is currently assigned to collect a specific bin.
     * Logic: Bin -> Route (Active/Assigned) -> Collector -> Truck
     */
    public TruckInventory getTruckForBin(String binId) {
        // 1. First, try to find a route that is currently IN_PROGRESS containing this bin
        Optional<Route> activeRoute = routeRepository.findByStopsBinIdAndStatus(binId, RouteStatusEnum.IN_PROGRESS);

        // 2. If no route is in progress, check if there is a route ASSIGNED (Driver might be on way to start)
        if (activeRoute.isEmpty()) {
            activeRoute = routeRepository.findByStopsBinIdAndStatus(binId, RouteStatusEnum.ASSIGNED);
        }

        // 3. If neither exists, we cannot track a truck
        if (activeRoute.isEmpty()) {
            throw new RuntimeException("No active or assigned collection route found for this bin.");
        }

        // 4. Get the Collector ID assigned to this route
        String collectorId = activeRoute.get().getAssignedToId();
        if (collectorId == null) {
            throw new RuntimeException("Route exists but no collector is assigned.");
        }

        // 5. Get the Truck assigned to this Collector
        TruckAssignment assignment = truckAssignmentRepository.findByCollectorId(collectorId)
                .orElseThrow(() -> new RuntimeException("Collector is not currently assigned to a truck."));

        // 6. Return the Truck Inventory (which holds the Lat/Lng)
        return truckInventoryRepository.findById(assignment.getTruckId())
                .orElseThrow(() -> new RuntimeException("Truck not found in inventory."));
    }

    /**
     * Updates the real-time GPS coordinates of a truck.
     * Called by the Driver App periodically.
     */
    public void updateTruckLocation(String truckId, Double lat, Double lng) {
        TruckInventory truck = truckInventoryRepository.findById(truckId)
                .orElseThrow(() -> new TruckNotFoundException("Truck not found"));

        truck.setLatitude(lat);
        truck.setLongitude(lng);

        truckInventoryRepository.save(truck);
    }
}