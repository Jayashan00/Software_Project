package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.CreateMaintenanceRequestDTO;
import com.smart_wastebackend.dto.MaintenanceRequestDTO;
import com.smart_wastebackend.model.MaintenanceRequests;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.enums.MaintenanceStatus;
import com.smart_wastebackend.enums.Priority;
import com.smart_wastebackend.repository.MaintenanceRequestRepository;
import com.smart_wastebackend.repository.UserTableRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class MaintenanceRequestService {

    private final MaintenanceRequestRepository maintenanceRequestRepository;
    private final UserTableRepository userTableRepository;
    private final NotificationService notificationService;
    private final MongoTemplate mongoTemplate;

    public String createRequest(CreateMaintenanceRequestDTO requestDTO, String requesterId) {
        try {
            String priorityStr = requestDTO.getPriority() != null ? requestDTO.getPriority().toUpperCase() : "MEDIUM";
            Priority priorityEnum;
            try {
                priorityEnum = Priority.valueOf(priorityStr);
            } catch (IllegalArgumentException e) {
                priorityEnum = Priority.MEDIUM;
            }

            MaintenanceRequests request = MaintenanceRequests.builder()
                    .binId(requestDTO.getBinId())
                    .requesterId(requesterId)
                    .requestType(requestDTO.getRequestType())
                    .description(requestDTO.getDescription())
                    .priority(priorityEnum)
                    .status(MaintenanceStatus.PENDING)
                    .notes(requestDTO.getNotes()) // ✅ Save initial notes if any
                    .createdAt(LocalDateTime.now())
                    .build();

            MaintenanceRequests saved = maintenanceRequestRepository.save(request);

            try {
                notificationService.createMaintenanceRequestNotification(saved.getId(), saved.getBinId(), saved.getDescription(), requesterId);
            } catch (Exception ignored) {}

            return saved.getId();
        } catch (Exception e) {
            log.error("Error creating maintenance request", e);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error creating request: " + e.getMessage());
        }
    }

    public MaintenanceRequestDTO updateRequestDetails(String id, CreateMaintenanceRequestDTO dto) {
        MaintenanceRequests request = maintenanceRequestRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Request not found"));

        request.setDescription(dto.getDescription());
        request.setRequestType(dto.getRequestType());

        // Also allow updating notes from the edit form
        if (dto.getNotes() != null) {
            request.setNotes(dto.getNotes());
        }

        if (dto.getPriority() != null) {
            try {
                request.setPriority(Priority.valueOf(dto.getPriority().toUpperCase()));
            } catch (IllegalArgumentException e) {
                // Keep old priority
            }
        }

        MaintenanceRequests updated = maintenanceRequestRepository.save(request);
        return convertToDTO(updated);
    }

    public void deleteRequest(String id) {
        if (!maintenanceRequestRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Request not found");
        }
        maintenanceRequestRepository.deleteById(id);
    }

    public Page<MaintenanceRequestDTO> getRequestsWithFilters(MaintenanceStatus status, String binId,
                                                              String requesterId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Query query = new Query();
        List<Criteria> criteria = new ArrayList<>();

        if (status != null) criteria.add(Criteria.where("status").is(status));
        if (binId != null && !binId.isEmpty()) criteria.add(Criteria.where("bin_id").is(binId));
        if (requesterId != null) criteria.add(Criteria.where("requester_id").is(requesterId));

        if (!criteria.isEmpty()) {
            query.addCriteria(new Criteria().andOperator(criteria.toArray(new Criteria[0])));
        }

        long totalCount = mongoTemplate.count(query, MaintenanceRequests.class);
        query.with(pageable);
        List<MaintenanceRequests> requests = mongoTemplate.find(query, MaintenanceRequests.class);

        List<MaintenanceRequestDTO> dtos = requests.stream().map(this::convertToDTO).collect(Collectors.toList());
        return new PageImpl<>(dtos, pageable, totalCount);
    }

    public void updateRequestStatus(String requestId, MaintenanceStatus status, String assignedTo, String notes) {
        MaintenanceRequests request = maintenanceRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Maintenance request not found"));

        request.setStatus(status);
        request.setAssignedTo(assignedTo);

        // ✅ Save the notes provided by Admin during status update
        if (notes != null && !notes.isEmpty()) {
            request.setNotes(notes);
        }

        if (status == MaintenanceStatus.COMPLETED) {
            request.setResolvedAt(LocalDateTime.now());

            try {
                notificationService.createMaintenanceCompletedNotification(
                        request.getId(),
                        request.getBinId(),
                        request.getRequesterId(),
                        notes != null ? notes : "Issue resolved."
                );
                log.info("Completion notification sent to user: {}", request.getRequesterId());
            } catch (Exception e) {
                log.error("Failed to send completion notification", e);
            }
        }

        maintenanceRequestRepository.save(request);
    }

    public MaintenanceRequestDTO getRequestById(String requestId) {
        MaintenanceRequests request = maintenanceRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Request not found"));
        return convertToDTO(request);
    }

    private MaintenanceRequestDTO convertToDTO(MaintenanceRequests request) {
        String requesterName = "Unknown";
        String assignedToName = "Unassigned";

        if (request.getRequesterId() != null) {
            requesterName = userTableRepository.findById(request.getRequesterId())
                    .map(UserTable::getUsername).orElse("Unknown User");
        }
        if (request.getAssignedTo() != null) {
            assignedToName = userTableRepository.findById(request.getAssignedTo())
                    .map(UserTable::getUsername).orElse("Unknown Staff");
        }

        return MaintenanceRequestDTO.builder()
                .id(request.getId())
                .binId(request.getBinId())
                .requesterId(request.getRequesterId())
                .requesterName(requesterName)
                .requestType(request.getRequestType())
                .description(request.getDescription())
                .priority(request.getPriority() != null ? request.getPriority().name() : "MEDIUM")
                .status(request.getStatus() != null ? request.getStatus().name() : "PENDING")
                .createdAt(request.getCreatedAt())
                .resolvedAt(request.getResolvedAt())
                .assignedTo(request.getAssignedTo())
                .assignedToName(assignedToName)
                .notes(request.getNotes()) // ✅ FIXED: Now fetching from the model
                .build();
    }
}