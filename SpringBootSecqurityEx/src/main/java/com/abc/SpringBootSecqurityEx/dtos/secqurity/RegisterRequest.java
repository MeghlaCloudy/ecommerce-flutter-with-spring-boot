package com.abc.SpringBootSecqurityEx.dtos.secqurity;


public record RegisterRequest(
        String username,
        String password,
        String email,
        String firstName,
        String lastName
) {}
