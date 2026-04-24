package com.abc.SpringBootSecqurityEx.dtos;

import com.abc.SpringBootSecqurityEx.entity.Cart;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Data
public class CartDto {

    private Long cartId;
    private List<ItemDto> items;
    private BigDecimal totalAmount;


}
