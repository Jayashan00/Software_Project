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
@Document(collection = "bin_owner_profiles")
public class BinOwnerProfile {

    /**
     * This ID is the same as the UserTable ID it refers to.
     */
    @Id
    private String id;

    @Field("name")
    private String name;

    @Field("address")
    private String address;

    @Field("mobile_number")
    private String mobileNumber;

    @Field("is_email_verified")
    private boolean isEmailVerified;
}