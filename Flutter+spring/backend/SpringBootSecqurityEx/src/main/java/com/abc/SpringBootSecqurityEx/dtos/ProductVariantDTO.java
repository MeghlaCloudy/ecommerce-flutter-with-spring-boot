package com.abc.SpringBootSecqurityEx.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductVariantDTO {

    private Long id;

    @NotBlank
    private String variantName;   // Color, Size, RAM

    @NotBlank
    private String variantValue;  // Red, XL, 8GB

    private BigDecimal priceAdjustment;

    @PositiveOrZero
    private Integer stock;

    @NotNull
    private Long productId;
}
