package com.abc.SpringBootSecqurityEx.dtos;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Data
@Builder
public class ProductResponseDTO {

    private Long id;
    private String name;
    private String description;

    private BigDecimal price;
    private BigDecimal discountPrice;

    private Boolean active;
    private String sku;
    private Integer stockQuantity;

    private String brandName;
    private Set<String> categories;
    private List<String> images;

    private LocalDateTime createdAt;
}
