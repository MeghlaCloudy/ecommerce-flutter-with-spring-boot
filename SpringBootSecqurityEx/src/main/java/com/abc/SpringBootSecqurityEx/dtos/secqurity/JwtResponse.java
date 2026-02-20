package com.abc.SpringBootSecqurityEx.dtos.secqurity;



import com.abc.SpringBootSecqurityEx.entity.User;

public record JwtResponse(
        String jwtToken,
        User user
) {}