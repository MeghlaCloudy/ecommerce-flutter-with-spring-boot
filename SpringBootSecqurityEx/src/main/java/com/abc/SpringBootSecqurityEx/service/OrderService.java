package com.abc.SpringBootSecqurityEx.service;

import com.abc.SpringBootSecqurityEx.dtos.CheckoutRequest;
import com.abc.SpringBootSecqurityEx.dtos.ItemDto;
import com.abc.SpringBootSecqurityEx.dtos.OrderDto;
import com.abc.SpringBootSecqurityEx.entity.*;
import com.abc.SpringBootSecqurityEx.enums.OrderStatus;
import com.abc.SpringBootSecqurityEx.repository.CartRepository;
import com.abc.SpringBootSecqurityEx.repository.OrderRepository;
import com.abc.SpringBootSecqurityEx.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final CartRepository cartRepository;

    private User getCurrentUser() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findById(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    // নতুন: CheckoutRequest দিয়ে অ্যাড্রেস গ্রহণ করা
    public OrderDto createOrder(CheckoutRequest request) {
        User user = getCurrentUser();
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        if (cart.getItems().isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }

        Order order = new Order();
        order.setUser(user);
        order.setStatus(OrderStatus.PENDING);
        order.setPaymentMethod(request.getPaymentMethod());

        // Cart items → Order items
        order.setItems(cart.getItems().stream().map(cartItem -> {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(cartItem.getProduct());
            orderItem.setQuantity(cartItem.getQuantity());
            return orderItem;
        }).collect(Collectors.toList()));

        // Total amount calculate
        BigDecimal totalAmount = order.getItems().stream()
                .map(OrderItem::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        order.setTotalAmount(totalAmount);

        // নতুন: ইউজার যে অ্যাড্রেস ফর্মে লিখেছে সেটা Order-এ সেভ করো
        Address shippingAddress = new Address();
        shippingAddress.setStreet(request.getStreet());
        shippingAddress.setCity(request.getCity());
        shippingAddress.setCountry(request.getCountry());
        shippingAddress.setZipCode(request.getZipCode());
        shippingAddress.setUser(user);  // ইউজারের সাথে লিঙ্ক

        order.setShippingAddress(shippingAddress);

        orderRepository.save(order);

        // কার্ট ক্লিয়ার
        cart.getItems().clear();
        cartRepository.save(cart);

        return mapOrderToDto(order);
    }

    // বাকি মেথডগুলো আগের মতোই থাকবে (getUserOrders, getOrder, getAllOrders, updateOrderStatus)

    public List<OrderDto> getUserOrders() {
        User user = getCurrentUser();
        return orderRepository.findByUser(user).stream()
                .map(this::mapOrderToDto)
                .collect(Collectors.toList());
    }

    public OrderDto getOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return mapOrderToDto(order);
    }

    public List<OrderDto> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::mapOrderToDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public OrderDto updateOrderStatus(Long orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        order.setStatus(newStatus);
        orderRepository.save(order);
        return mapOrderToDto(order);
    }

    private OrderDto mapOrderToDto(Order order) {
        OrderDto dto = new OrderDto();
        dto.setOrderId(order.getId());
        dto.setTotalAmount(order.getTotalAmount());
        dto.setStatus(order.getStatus());
        dto.setPaymentMethod(order.getPaymentMethod());
        dto.setCreatedAt(order.getCreatedAt());
        dto.setUserName(order.getUser() != null ? order.getUser().getUserName() : "Unknown");

        // শিপিং অ্যাড্রেস ইনফো
        if (order.getShippingAddress() != null) {
            Address addr = order.getShippingAddress();
            dto.setShippingAddressInfo(
                    addr.getStreet() + ", " +
                            addr.getCity() + ", " +
                            addr.getCountry() + " - " +
                            addr.getZipCode()
            );
        } else {
            dto.setShippingAddressInfo("No shipping address");
        }

        dto.setItems(order.getItems().stream().map(orderItem -> {
            ItemDto itemDto = new ItemDto();
            itemDto.setItemId(orderItem.getId());
            itemDto.setProductId(orderItem.getProduct().getId());
            itemDto.setProductName(orderItem.getProduct().getName());
            itemDto.setQuantity(orderItem.getQuantity());
            itemDto.setPrice(orderItem.getProduct().getPrice());
            itemDto.setTotal(orderItem.getTotalPrice());

            try {
                itemDto.setImageUrl(orderItem.getProduct().getImages().get(0).getImageUrl());
            } catch (Exception e) {
                itemDto.setImageUrl(null);
            }
            return itemDto;
        }).collect(Collectors.toList()));

        return dto;
    }
}