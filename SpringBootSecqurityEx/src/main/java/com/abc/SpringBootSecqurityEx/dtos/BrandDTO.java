package com.abc.SpringBootSecqurityEx.dtos;


import com.abc.SpringBootSecqurityEx.entity.Brand;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BrandDTO {

    private Long id;

    @NotBlank
    private String name;
    private String description;
    private String logoUrl;

}
