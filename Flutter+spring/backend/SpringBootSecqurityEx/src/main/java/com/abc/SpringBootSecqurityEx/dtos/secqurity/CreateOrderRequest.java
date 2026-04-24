package com.abc.SpringBootSecqurityEx.dtos.secqurity;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateOrderRequest {

    @NotBlank
    private String paymentMethod;
}

