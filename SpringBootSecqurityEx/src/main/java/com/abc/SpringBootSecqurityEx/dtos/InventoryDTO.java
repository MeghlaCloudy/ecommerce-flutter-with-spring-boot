package com.abc.SpringBootSecqurityEx.dtos;


import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class InventoryDTO {

    private Long id;

    @NotNull
    private Long productId;

    @PositiveOrZero
    private Integer availableQuantity;

    @PositiveOrZero
    private Integer reservedQuantity;
}
