package com.abc.SpringBootSecqurityEx.dtos;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductReviewDTO {

    private Long id;

    @Min(1)
    @Max(5)
    private Integer rating;

    private String comment;

    @NotNull
    private Long productId;

    @NotNull
    private String userId;
}
