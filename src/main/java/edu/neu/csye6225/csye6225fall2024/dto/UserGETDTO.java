package edu.neu.csye6225.csye6225fall2024.dto;

import java.time.LocalDateTime;

public class UserGETDTO {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private LocalDateTime accountCreated;
    private LocalDateTime accountUpdated;

    // Constructor
    public UserGETDTO(Long id, String email, String firstName, String lastName, LocalDateTime accountCreated, LocalDateTime accountUpdated) {
        this.id = id;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.accountCreated = accountCreated;
        this.accountUpdated = accountUpdated;
    }

    public String getEmail() {
        return email;
    }

    public Long getId() {
        return id;
    }

    public LocalDateTime getAccountCreated() {
        return accountCreated;
    }

    public LocalDateTime getAccountUpdated() {
        return accountUpdated;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setEmail(String emailAddress) {
        this.email = emailAddress;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setAccountCreated(LocalDateTime accountCreated) {
        this.accountCreated = accountCreated;
    }

    public void setAccountUpdated(LocalDateTime accountUpdated) {
        this.accountUpdated = accountUpdated;
    }
}
