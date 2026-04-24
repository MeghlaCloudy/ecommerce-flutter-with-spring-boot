package com.abc.SpringBootSecqurityEx.dtos;

import com.abc.SpringBootSecqurityEx.enums.OrderStatus;
import com.abc.SpringBootSecqurityEx.enums.PaymentStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderDto {

    private Long orderId;
    private OrderStatus status;
    private PaymentStatus paymentStatus;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private List<ItemDto> items;

    // নতুন যোগ করা ফিল্ড
    private LocalDateTime createdAt;

    // অ্যাডমিনের জন্য ইউজারের নাম দেখানোর জন্য (অপশনাল কিন্তু ভালো লাগবে)
    private String userName;

    private String shippingAddressInfo;
}