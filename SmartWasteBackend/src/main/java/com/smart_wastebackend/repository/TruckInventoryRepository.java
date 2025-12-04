package com.smart_wastebackend.repository;

import com.smart_wastebackend.enums.TruckStatusEnum;
import com.smart_wastebackend.model.TruckInventory;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TruckInventoryRepository extends MongoRepository<TruckInventory, String> {

    List<TruckInventory> findByStatusAndCapacityKgGreaterThanEqual(TruckStatusEnum status, Long minCapacityKg);

    List<TruckInventory> findByStatus(TruckStatusEnum status);

    List<TruckInventory> findByCapacityKgGreaterThanEqual(Long minCapacityKg);

    Optional<TruckInventory> findByRegistrationNumber(String registrationNumber);
}