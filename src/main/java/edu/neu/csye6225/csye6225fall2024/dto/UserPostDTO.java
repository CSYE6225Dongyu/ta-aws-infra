package edu.neu.csye6225.csye6225fall2024.dto;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.lang.NonNull;

@JsonIgnoreProperties(ignoreUnknown = false) // not allow other filed and not working
public class UserPostDTO {
    private String email;
    private String password;
    private String firstName;
    private String lastName;

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
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

    public void setPassword(String password) {
        this.password = password;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
}
