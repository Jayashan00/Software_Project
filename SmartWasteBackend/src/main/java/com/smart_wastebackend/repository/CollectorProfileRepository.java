package com.smart_wastebackend.repository;

import com.smart_wastebackend.model.CollectorProfile;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List; // <-- ADD THIS IMPORT

@Repository
public interface CollectorProfileRepository extends MongoRepository<CollectorProfile, String> {

    CollectorProfile findByName(String name);

    // --- ADD THIS METHOD ---
    // Finds all collector profiles where the ID is NOT IN the provided list
    List<CollectorProfile> findByIdNotIn(List<String> ids);
    // --- END ---
}