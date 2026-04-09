package com.smartclinic.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DoctorRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String speciality;

    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;

    private String phone;
}
