package com.abc.SpringBootSecqurityEx.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
public class Cart extends BaseEntity {

    @OneToOne
    private User user;


    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CartItem> items = new ArrayList<>();

    // Total amount of the cart. This should be updated whenever items are added/removed.
    private BigDecimal totalAmount;

    // Indicates if the cart is still active (i.e., user hasn't checked out yet).
    private Boolean active = true;

    public void calculateTotalAmount() {
        this.totalAmount = this.items.stream()
                .map(CartItem::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
//    public void calculateTotalAmount() {
//        this.totalAmount = this.items.stream()
//                .map(item -> item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity())))
//                .reduce(BigDecimal.ZERO, BigDecimal::add);
//    }
}
