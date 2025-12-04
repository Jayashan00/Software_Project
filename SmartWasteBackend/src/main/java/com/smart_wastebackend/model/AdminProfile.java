package com.smart_wastebackend.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "admin_profiles")
public class AdminProfile {

    /**
     * This ID is the same as the UserTable ID it refers to.
     */
    @Id
    private String id;

    @Field("name")
    private String name;
}