package com.smart_wastebackend.repository;

import com.smart_wastebackend.enums.BinStatusEnum;
import com.smart_wastebackend.model.BinInventory;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BinInventoryRepository extends MongoRepository<BinInventory, String> {

    List<BinInventory> findByStatusAndOwnerId(BinStatusEnum status, String ownerId);

    List<BinInventory> findByStatus(BinStatusEnum status);

    List<BinInventory> findByOwnerId(String ownerId);

    // CRITICAL METHOD - MUST BE HERE
    List<BinInventory> findByOwnerIdAndStatus(String ownerId, BinStatusEnum status);

    // Merged from BinStatusRepository (querying embedded fields)
    @Query("{'$or': [{'plasticLevel': {'$gt': ?0}}, {'paperLevel': {'$gt': ?0}}, {'glassLevel': {'$gt': ?0}}]}")
    List<BinInventory> findBinsWithHighFillLevel(Long level);

    List<BinInventory> findByPlasticLevelGreaterThanEqual(Long threshold);

    List<BinInventory> findByPaperLevelGreaterThanEqual(Long threshold);

    List<BinInventory> findByGlassLevelGreaterThanEqual(Long threshold);

    List<BinInventory> findByLastEmptiedAtBeforeOrLastEmptiedAtIsNull(LocalDateTime date);
}