package com.abc.SpringBootSecqurityEx.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;

@Data
public class ProductRequestDTO {

    @NotBlank
    private String name;

    private String description;

    @NotNull
    @Positive
    private BigDecimal price;

    private BigDecimal discountPrice;

    private String sku;

    @NotNull
    @PositiveOrZero
    private Integer stockQuantity;

    private Long brandId;

    private Set<Long> categoryIds;

    private List<String> imageUrls;
}
