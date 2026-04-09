package com.smartclinic.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class PrescriptionRequest {

    @NotNull
    private Long appointmentId;

    @NotNull
    private Long doctorId;

    @NotNull
    private Long patientId;

    @NotBlank
    private String medication;

    private String dosage;

    private String instructions;
}
