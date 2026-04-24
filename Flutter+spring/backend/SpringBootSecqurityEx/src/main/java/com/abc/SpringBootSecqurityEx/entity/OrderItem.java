package com.abc.SpringBootSecqurityEx.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Getter
@Setter
public class OrderItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    private Product product;


    private Integer quantity;
//    private BigDecimal price;
    // Calculate total price for this cart item
    public BigDecimal getTotalPrice() {
        return product.getPrice().multiply(new BigDecimal(quantity));
    }
}
