package edu.neu.csye6225.csye6225fall2024.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import edu.neu.csye6225.csye6225fall2024.config.AuthorizeConfig;
import edu.neu.csye6225.csye6225fall2024.dto.UserGETDTO;
import edu.neu.csye6225.csye6225fall2024.dto.UserPostDTO;
import edu.neu.csye6225.csye6225fall2024.service.UserService;
import edu.neu.csye6225.csye6225fall2024.service.ValidateFields;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(UserController.class)
@Import(AuthorizeConfig.class)
@ActiveProfiles("test")
public class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private ValidateFields validateFields;

    @MockBean
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    // Simulate the password encoding process
    @BeforeEach
    void setUp() {
        // Simulating the encoding of the password
        given(passwordEncoder.encode("TestPassword123")).willReturn("encodedPassword");
    }

    @Test
    void testCreateUser() throws Exception {
        // Mock the request body for creating a user
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("firstName", "John");
        requestBody.put("lastName", "Doe");
        requestBody.put("email", "john.doe@example.com");
        requestBody.put("password", "TestPassword123");

        // Create DTO objects for the user
        UserPostDTO userPostDTO = new UserPostDTO();
        userPostDTO.setFirstName("John");
        userPostDTO.setLastName("Doe");
        userPostDTO.setEmail("john.doe@example.com");
        userPostDTO.setPassword("TestPassword1234");

//        UserGETDTO returnUserPostDTO = new UserGETDTO();
        // Validate that the fields in the request are correct
        given(validateFields.postValidate(requestBody)).willReturn(null);

        // Simulate the user creation process, mocking the service call
        doNothing().when(userService).createUser(any(UserPostDTO.class));

        // Step 1: Create the user via POST request
        mockMvc.perform(post("/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(requestBody)))
                .andExpect(status().isCreated()) ; // Expect HTTP 201 Created status
//                .andExpect(jsonPath("$.email").value("john.doe@example.com"));  // Check returned email
    }

    @Test
    void testCreateUser2() throws Exception {
        // Mock the request body for creating a user
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("firstName", "John");
        requestBody.put("lastName", "Doe");
        requestBody.put("email", "john.doe@example.com");
        requestBody.put("password", "TestPassword123");

        // Mock返回用户
        UserGETDTO userGETDTO = new UserGETDTO();
        userGETDTO.setEmail("john.doe@example.com");
        userGETDTO.setFirstName("John");
        userGETDTO.setLastName("Doe");

        // validate body
        given(validateFields.postValidate(requestBody)).willReturn(null);

        // create user
        doNothing().when(userService).createUser(any(UserPostDTO.class));

        // return the get info
        given(userService.getUserByEmail("john.doe@example.com")).willReturn(userGETDTO);

        // post
        mockMvc.perform(post("/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(requestBody)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.email").value("john.doe@example.com"))
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"));
    }

//    @Test
//    void testGetUser_WithAuth() throws Exception {
//
//        // Mock the request body for creating a user
//        Map<String, Object> requestBody = new HashMap<>();
//        requestBody.put("firstName", "John");
//        requestBody.put("lastName", "Doe");
//        requestBody.put("email", "john.doe@example.com");
//        requestBody.put("password", "TestPassword123");
//
//        // Mock返回用户
//        UserGETDTO userGETDTO = new UserGETDTO();
//        userGETDTO.setEmail("john.doe@example.com");
//        userGETDTO.setFirstName("John");
//        userGETDTO.setLastName("Doe");
//
//        // 模拟字段验证
//        given(validateFields.postValidate(requestBody)).willReturn(null);
//
//        // 模拟创建用户行为
//        doNothing().when(userService).createUser(any(UserPostDTO.class));
//
//        // 当使用该邮箱查询时，返回模拟的userGETDTO
//        given(userService.getUserByEmail("john.doe@example.com")).willReturn(userGETDTO);
//
//        mockMvc.perform(post("/v1/users")
//                .contentType(MediaType.APPLICATION_JSON)
//                .content(objectMapper.writeValueAsString(requestBody)));
//
//        userGETDTO.setEmail("john.doe@example.com");
//
//        // Mock the service call to return the user info when queried by email
//        given(userService.getUserByEmail("john.doe@example.com")).willReturn(userGETDTO);
//
//        // Step 2: Get the user info via GET request with Basic Auth
//        mockMvc.perform(get("/v1/users/self")
//                        .with(httpBasic("john.doe@example.com", "TestPassword123")))  // Provide credentials
//                .andExpect(status().isOk())  // Expect HTTP 200 OK status
//                .andExpect(jsonPath("$.email").value("john.doe@example.com"));  // Check returned email
//    }
}
