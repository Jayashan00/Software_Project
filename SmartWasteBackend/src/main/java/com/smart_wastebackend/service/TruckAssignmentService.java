package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.TruckAssignmentRequestDTO;
import com.smart_wastebackend.dto.TruckAssignmentResponseDTO;
import com.smart_wastebackend.enums.TruckStatusEnum;
import com.smart_wastebackend.exception.TruckNotFoundException;
import com.smart_wastebackend.exception.UserNotFoundException;
import com.smart_wastebackend.model.CollectorProfile;
import com.smart_wastebackend.model.TruckAssignment;
import com.smart_wastebackend.model.TruckInventory;
import com.smart_wastebackend.repository.CollectorProfileRepository;
import com.smart_wastebackend.repository.TruckAssignmentRepository;
import com.smart_wastebackend.repository.TruckInventoryRepository;
import org.springframework.transaction.annotation.Transactional;
import jakarta.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class TruckAssignmentService {

    private final TruckInventoryRepository truckInventoryRepository;
    private final CollectorProfileRepository collectorProfileRepository;
    private final TruckAssignmentRepository truckAssignmentRepository;

    @Autowired
    public TruckAssignmentService(
            TruckInventoryRepository truckInventoryRepository,
            CollectorProfileRepository collectorProfileRepository,
            TruckAssignmentRepository truckAssignmentRepository
    ) {
        this.truckInventoryRepository = truckInventoryRepository;
        this.collectorProfileRepository = collectorProfileRepository;
        this.truckAssignmentRepository = truckAssignmentRepository;
    }

    // --- ADD THIS NEW METHOD ---
    @Transactional(readOnly = true)
    public ApiResponse<List<CollectorProfile>> getAvailableCollectors() {
        // 1. Find all collectors who are *already* assigned to a truck
        List<String> assignedCollectorIds = truckAssignmentRepository.findAll()
                .stream()
                .map(TruckAssignment::getCollectorId)
                .collect(Collectors.toList());

        // 2. Find all collector profiles *not in* that list
        List<CollectorProfile> availableCollectors = collectorProfileRepository.findByIdNotIn(assignedCollectorIds);

        return ApiResponse.<List<CollectorProfile>>builder()
                .success(true)
                .message("Available collectors fetched successfully")
                .data(availableCollectors)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }
    // --- END OF NEW METHOD ---

    @Transactional(readOnly = true)
    public ApiResponse<List<TruckAssignmentResponseDTO>> getAllTrucksWithCollectors() {
        List<CollectorProfile> allCollectors = collectorProfileRepository.findAll();

        List<TruckAssignmentResponseDTO> responseList = allCollectors.stream()
                .map(collector -> {
                    Optional<TruckAssignment> assignmentOpt = truckAssignmentRepository.findByCollectorId(collector.getId());

                    if (assignmentOpt.isEmpty()) {
                        return null;
                    }

                    TruckAssignment assignment = assignmentOpt.get();
                    TruckInventory truck = truckInventoryRepository.findById(assignment.getTruckId())
                            .orElse(null);

                    if (truck == null) {
                        return null;
                    }

                    return TruckAssignmentResponseDTO.builder()
                            .truck(truck)
                            .collector(collector)
                            .assignedDate(assignment.getAssignedDate().toString())
                            .build();
                })
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());

        return ApiResponse.<List<TruckAssignmentResponseDTO>>builder()
                .success(true)
                .message("Truck assignments successfully retrieved")
                .data(responseList)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<TruckAssignment> assignTruckToCollector(String registrationNumber, String collectorId) {
        TruckInventory truck = truckInventoryRepository.findByRegistrationNumber(registrationNumber)
                .orElseThrow(() -> new TruckNotFoundException("Truck with registration number " + registrationNumber + " not found"));

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

        return ApiResponse.<TruckAssignment>builder()
                .success(true)
                .message("Truck successfully assigned to collector")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<String> handOverTruck(String registrationNumber, String collectorId) {
        Optional<TruckInventory> optionalTruck = truckInventoryRepository.findByRegistrationNumber(registrationNumber);
        if (optionalTruck.isEmpty()) {
            return new ApiResponse<>(false, "Truck not found", null, LocalDateTime.now().toString());
        }
        TruckInventory truck = optionalTruck.get();

        Optional<TruckAssignment> optionalTruckAssignment = truckAssignmentRepository.findTopByTruckIdOrderByAssignedDateDesc(truck.getId());
        if (optionalTruckAssignment.isEmpty()) {
            return new ApiResponse<>(false, "Truck Assignment not found", null, LocalDateTime.now().toString());
        }
        TruckAssignment truckAssignment = optionalTruckAssignment.get();

        if (!truckAssignment.getCollectorId().equals(collectorId)) {
            return new ApiResponse<>(false, "Truck is not assigned to collector", null, LocalDateTime.now().toString());
        }
        if (truck.getStatus() != TruckStatusEnum.IN_SERVICE) {
            return new ApiResponse<>(false, "Truck is not in service", null, LocalDateTime.now().toString());
        }
        truck.setStatus(TruckStatusEnum.AVAILABLE);
        truckInventoryRepository.save(truck);

        truckAssignmentRepository.delete(truckAssignment);

        return new ApiResponse<>(true, "Truck successfully handed over", null, LocalDateTime.now().toString());
    }
}