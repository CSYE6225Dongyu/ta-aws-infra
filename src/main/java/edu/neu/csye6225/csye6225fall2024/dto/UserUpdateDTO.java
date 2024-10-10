package edu.neu.csye6225.csye6225fall2024.dto;

public class UserUpdateDTO {

    private String firstName;
    private String lastName;
    private String password;
    //for json Deserialization, use default constructor

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getPassword() {
        return password;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
