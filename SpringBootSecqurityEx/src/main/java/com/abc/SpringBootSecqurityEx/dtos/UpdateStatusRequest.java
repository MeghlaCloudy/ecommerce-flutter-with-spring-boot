package com.abc.SpringBootSecqurityEx.dtos;


import com.abc.SpringBootSecqurityEx.enums.OrderStatus;
import lombok.Data;

@Data
public class UpdateStatusRequest {
    private OrderStatus status;
}
