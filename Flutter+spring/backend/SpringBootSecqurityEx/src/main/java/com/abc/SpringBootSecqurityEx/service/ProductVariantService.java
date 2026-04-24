package com.abc.SpringBootSecqurityEx.service;


import com.abc.SpringBootSecqurityEx.dtos.ProductVariantDTO;
import com.abc.SpringBootSecqurityEx.entity.Product;
import com.abc.SpringBootSecqurityEx.entity.ProductVariant;
import com.abc.SpringBootSecqurityEx.repository.ProductRepository;
import com.abc.SpringBootSecqurityEx.repository.ProductVariantRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class ProductVariantService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository variantRepository;

        public void create(ProductVariantDTO dto) {

        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        ProductVariant variant = new ProductVariant();
        variant.setVariantName(dto.getVariantName());
        variant.setVariantValue(dto.getVariantValue());
        variant.setPriceAdjustment(dto.getPriceAdjustment());
        variant.setStock(dto.getStock());
        variant.setProduct(product);

        variantRepository.save(variant);
    }
}
