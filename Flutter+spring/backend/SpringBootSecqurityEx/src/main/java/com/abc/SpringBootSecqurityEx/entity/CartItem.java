package com.abc.SpringBootSecqurityEx.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Getter
@Setter
public class CartItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    private Cart cart;

    @ManyToOne(fetch = FetchType.LAZY)
    private Product product;

    private Integer quantity;

    // Calculate total price for this cart item
    public BigDecimal getTotalPrice() {
        return product.getPrice().multiply(new BigDecimal(quantity));
    }
}
