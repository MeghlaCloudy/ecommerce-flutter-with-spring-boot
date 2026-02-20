package com.abc.SpringBootSecqurityEx.dtos;


import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ApiResponse<T> {

    private Boolean success;
    private String message;
    private T data;
}
