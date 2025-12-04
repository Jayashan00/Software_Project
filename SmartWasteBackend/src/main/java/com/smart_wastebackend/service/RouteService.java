package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.*;
import com.smart_wastebackend.enums.RouteStatusEnum;
import com.smart_wastebackend.exception.BinNotFoundException;
import com.smart_wastebackend.exception.UserNotFoundException;
import com.smart_wastebackend.model.BinInventory;
import com.smart_wastebackend.model.CollectorProfile;
import com.smart_wastebackend.model.Route;
import com.smart_wastebackend.model.embedded.RouteStop;
import com.smart_wastebackend.repository.BinInventoryRepository;
import com.smart_wastebackend.repository.CollectorProfileRepository;
import com.smart_wastebackend.repository.RouteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate; // ✅ Added for Calendar logic
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
@Transactional
public class RouteService {

    private final RouteRepository routeRepository;
    private final BinInventoryRepository binInventoryRepository;
    private final CollectorProfileRepository collectorProfileRepository;
    private final NotificationService notificationService; // ✅ Inject NotificationService

    @Autowired
    public RouteService(
            RouteRepository routeRepository,
            BinInventoryRepository binInventoryRepository,
            CollectorProfileRepository collectorProfileRepository,
            NotificationService notificationService // ✅ Add to Constructor
    ) {
        this.routeRepository = routeRepository;
        this.binInventoryRepository = binInventoryRepository;
        this.collectorProfileRepository = collectorProfileRepository;
        this.notificationService = notificationService;
    }

    public ApiResponse<List<Route>> getAllRoutes() {
        List<Route> routes = routeRepository.findAll();
        return ApiResponse.<List<Route>>builder()
                .success(true)
                .message("Routes fetched successfully")
                .data(routes)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<Route> createRoute(CreateRouteRequestDTO request) {
        Route route = new Route();
        route.setDateCreated(LocalDateTime.now());
        route.setStatus(RouteStatusEnum.CREATED);
        route.setName(request.getName());
        route.setStops(buildRouteStops(request.getBinIds()));

        Route savedRoute = routeRepository.save(route);
        return ApiResponse.<Route>builder()
                .success(true)
                .message("Route created successfully")
                .data(savedRoute)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<Route> updateRoute(String routeId, CreateRouteRequestDTO request) {
        Route route = routeRepository.findById(routeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Route not found"));

        if (route.getStatus() == RouteStatusEnum.IN_PROGRESS) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cannot edit a route that is in progress");
        }

        route.setName(request.getName());
        route.setStops(buildRouteStops(request.getBinIds()));
        route.setStatus(RouteStatusEnum.CREATED);
        route.setAssignedToId(null);

        Route updatedRoute = routeRepository.save(route);
        return ApiResponse.<Route>builder()
                .success(true)
                .message("Route updated successfully")
                .data(updatedRoute)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<Void> deleteRoute(String routeId) {
        Route route = routeRepository.findById(routeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Route not found"));

        if (route.getStatus() == RouteStatusEnum.IN_PROGRESS || route.getStatus() == RouteStatusEnum.ASSIGNED) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cannot delete a route that is active or assigned");
        }

        routeRepository.delete(route);

        return ApiResponse.<Void>builder()
                .success(true)
                .message("Route deleted successfully")
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    private List<RouteStop> buildRouteStops(List<String> binIds) {
        AtomicLong stopOrder = new AtomicLong(1);
        return binIds.stream()
                .map(binId -> {
                    BinInventory bin = binInventoryRepository.findById(binId)
                            .orElseThrow(() -> new BinNotFoundException("Bin not found with ID: " + binId));

                    RouteStop stop = new RouteStop();
                    stop.setBinId(bin.getBinId());
                    stop.setLatitude(bin.getLatitude());
                    stop.setLongitude(bin.getLongitude());
                    stop.setStopOrder(stopOrder.getAndIncrement());
                    return stop;
                })
                .collect(Collectors.toList());
    }

    // ✅ UPDATED METHOD: Assigns Route AND Notifies Bin Owners
    public ApiResponse<Route> assignRouteToCollector(String routeId, String collectorId) {
        CollectorProfile collectorProfile = collectorProfileRepository.findById(collectorId)
                .orElseThrow(() -> new UserNotFoundException("Collector with ID '" + collectorId + "' not found"));

        Route route = routeRepository.findById(routeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Route with ID '" + routeId + "' not found"));

        if (route.getStatus() == RouteStatusEnum.IN_PROGRESS) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Route is already in progress");
        }

        route.setStatus(RouteStatusEnum.ASSIGNED);
        route.setAssignedToId(collectorProfile.getId());
        routeRepository.save(route);

        // --- CALENDAR AUTOMATION ---
        List<RouteStop> stops = route.getStops();
        if (stops != null) {
            for (RouteStop stop : stops) {
                try {
                    BinInventory bin = binInventoryRepository.findById(stop.getBinId()).orElse(null);

                    // Only notify if bin exists and has an owner
                    if (bin != null && bin.getOwnerId() != null) {
                        notificationService.createCollectionDateNotification(
                                bin.getBinId(),
                                bin.getOwnerId(),
                                LocalDate.now().plusDays(1) // Schedule for Tomorrow
                        );
                    }
                } catch (Exception e) {
                    // Log error but don't fail the assignment transaction
                    System.err.println("Failed to notify bin owner for bin: " + stop.getBinId());
                }
            }
        }
        // -----------------------------

        return ApiResponse.<Route>builder()
                .success(true)
                .message("Route " + routeId + " successfully assigned to " + collectorProfile.getName())
                .data(route)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<AssignedRouteResponseDTO> getAssignedRoute(String collectorId) {
        Optional<CollectorProfile> optionalCollectorProfile = collectorProfileRepository.findById(collectorId);
        if (optionalCollectorProfile.isEmpty()) {
            return new ApiResponse<>(false,"Collector not found",null,LocalDateTime.now().toString());
        }
        CollectorProfile collectorProfile = optionalCollectorProfile.get();

        Optional<Route> optionalRoute = routeRepository.findFirstByAssignedToIdAndStatusOrderByDateCreatedDesc(collectorProfile.getId(), RouteStatusEnum.ASSIGNED);

        if (optionalRoute.isEmpty()) {
            return new ApiResponse<>(
                    false,
                    "No assigned route found for the collector",
                    null,
                    LocalDateTime.now().toString()
            );
        }

        Route route = optionalRoute.get();

        List<BinStopDTO> binStops = route.getStops()
                .stream()
                .map(stop -> {
                    BinInventory bin = binInventoryRepository.findById(stop.getBinId())
                            .orElse(null);

                    if (bin == null) {
                        return null;
                    }

                    return new BinStopDTO(
                            stop.getStopOrder(),
                            bin.getBinId(),
                            stop.getLatitude(),
                            stop.getLongitude(),
                            bin.getPaperLevel(),
                            bin.getPlasticLevel(),
                            bin.getGlassLevel(),
                            bin.getLastEmptiedAt()
                    );
                })
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());


        AssignedRouteResponseDTO responseDTO = new AssignedRouteResponseDTO(
                route.getId(),
                route.getStatus(),
                route.getRouteStartTime(),
                route.getRouteEndTime(),
                binStops
        );

        return new ApiResponse<>(
                true,
                "Assigned route retrieved successfully",
                responseDTO,
                LocalDateTime.now().toString()
        );
    }

    public ApiResponse<String> startRoute(String collectorId, String routeId) {
        Optional<Route> optionalRoute = routeRepository.findById(routeId);
        if (optionalRoute.isEmpty()) {
            return new ApiResponse<>(false, "Route not found", null, LocalDateTime.now().toString());
        }

        Route route = optionalRoute.get();
        if (!route.getAssignedToId().equals(collectorId)) {
            return new ApiResponse<>(false, "You are not authorized to start this route", null, LocalDateTime.now().toString());
        }

        if (!route.getStatus().equals(RouteStatusEnum.ASSIGNED)) {
            return new ApiResponse<>(false, "Route is not in a valid state to be started", null, LocalDateTime.now().toString());
        }
        route.setStatus(RouteStatusEnum.IN_PROGRESS);
        route.setRouteStartTime(LocalDateTime.now());
        routeRepository.save(route);

        return new ApiResponse<>(true, "Successfully updated the Started time", null, LocalDateTime.now().toString()
        );
    }

    public ApiResponse<String> markAsCollected(String collectorId, MarkBinCollectedRequestDTO request) {
        Optional<Route> optionalRoute = routeRepository.findById(request.getRouteId());
        if (optionalRoute.isEmpty()) {
            return new ApiResponse<>(false, "Route not found", null, LocalDateTime.now().toString());
        }

        Route route = optionalRoute.get();
        if(!route.getAssignedToId().equals(collectorId)) {
            return new ApiResponse<>(false, "You are not authorized", null, LocalDateTime.now().toString());
        }
        if (!route.getStatus().equals(RouteStatusEnum.IN_PROGRESS)) {
            return new ApiResponse<>(false, "Cannot collect bin: Route is not ongoing", null, LocalDateTime.now().toString());
        }

        boolean binInRoute = routeRepository.existsByIdAndStopsBinId(route.getId(), request.getBinId());
        if (!binInRoute) {
            return new ApiResponse<>(false, "Bin is not part of this route", null, LocalDateTime.now().toString());
        }

        var binInventory = binInventoryRepository.findById(request.getBinId())
                .orElseThrow(() -> new RuntimeException("Bin status not found"));

        binInventory.setPaperLevel(0L);
        binInventory.setPlasticLevel(0L);
        binInventory.setGlassLevel(0L);
        binInventory.setLastEmptiedAt(LocalDateTime.now());

        binInventoryRepository.save(binInventory);

        return new ApiResponse<>(true, "Bin marked as collected", null, LocalDateTime.now().toString());
    }

    public ApiResponse<String> stopRoute(String collectorId, String routeId) {
        Optional<Route> optionalRoute = routeRepository.findById(routeId);
        if (optionalRoute.isEmpty()) {
            return new ApiResponse<>(false, "Route not found", null, LocalDateTime.now().toString());
        }
        Route route = optionalRoute.get();

        if(!route.getAssignedToId().equals(collectorId)) {
            return new ApiResponse<>(false, "You are not authorized to stop this route", null, LocalDateTime.now().toString());
        }

        if (!route.getStatus().equals(RouteStatusEnum.IN_PROGRESS)) {
            return new ApiResponse<>(false, "Cannot stop this route", null, LocalDateTime.now().toString());
        }
        route.setStatus(RouteStatusEnum.COMPLETED);
        route.setRouteEndTime(LocalDateTime.now());
        routeRepository.save(route);
        return new ApiResponse<>(true, "Route completed successfully", null, LocalDateTime.now().toString());
    }
}