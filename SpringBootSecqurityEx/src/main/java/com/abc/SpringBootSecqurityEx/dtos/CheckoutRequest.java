package com.abc.SpringBootSecqurityEx.dtos;

import lombok.Data;

@Data
public class CheckoutRequest {
    private String paymentMethod;
    private String street;
    private String city;
    private String country;
    private String zipCode;
}