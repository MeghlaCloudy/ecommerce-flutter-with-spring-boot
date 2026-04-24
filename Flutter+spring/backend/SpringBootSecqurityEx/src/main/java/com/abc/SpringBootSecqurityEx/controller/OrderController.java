package com.abc.SpringBootSecqurityEx.controller;

import com.abc.SpringBootSecqurityEx.dtos.CheckoutRequest;
import com.abc.SpringBootSecqurityEx.dtos.OrderDto;
import com.abc.SpringBootSecqurityEx.dtos.UpdateStatusRequest;
import com.abc.SpringBootSecqurityEx.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // User: Create order from cart
    @PostMapping("/checkout")
    public OrderDto checkout(@RequestBody CheckoutRequest request) {
        return orderService.createOrder(request);
    }

    // User: Get all orders of current logged-in user
    @GetMapping
    public List<OrderDto> getUserOrders() {
        return orderService.getUserOrders();
    }

    // User: Get single order by ID
    @GetMapping("/{id}")
    public OrderDto getOrder(@PathVariable("id") Long id) {
        return orderService.getOrder(id);
    }

    // ADMIN ONLY: Get ALL orders from all users
    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")   // শুধু ADMIN দেখতে পারবে
    public List<OrderDto> getAllOrders() {
        return orderService.getAllOrders();
    }


    // ADMIN ONLY: Update order status
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public OrderDto updateOrderStatus(
            @PathVariable Long id,
            @RequestBody UpdateStatusRequest request) {
        return orderService.updateOrderStatus(id, request.getStatus());
    }
}