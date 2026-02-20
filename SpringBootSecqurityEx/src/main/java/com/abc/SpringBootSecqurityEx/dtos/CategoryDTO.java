package com.abc.SpringBootSecqurityEx.dtos;


import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CategoryDTO {

    private Long id;

    @NotBlank
    private String name;

    private String imageUrl;

    private Long parentId; // for sub-categories
}
