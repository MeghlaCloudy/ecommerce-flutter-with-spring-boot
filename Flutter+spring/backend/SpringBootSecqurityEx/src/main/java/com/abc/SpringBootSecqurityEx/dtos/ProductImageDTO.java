package com.abc.SpringBootSecqurityEx.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductImageDTO {

    private Long id;

    @NotBlank
    private String imageUrl;

    private Boolean primaryImage;

    @NotNull
    private Long productId;
}
