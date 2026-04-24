package com.abc.SpringBootSecqurityEx.service;

import com.abc.SpringBootSecqurityEx.dtos.ProductRequestDTO;
import com.abc.SpringBootSecqurityEx.dtos.ProductResponseDTO;
import com.abc.SpringBootSecqurityEx.entity.Brand;
import com.abc.SpringBootSecqurityEx.entity.Category;
import com.abc.SpringBootSecqurityEx.entity.Product;
import com.abc.SpringBootSecqurityEx.entity.ProductImage;
import com.abc.SpringBootSecqurityEx.repository.BrandRepository;
import com.abc.SpringBootSecqurityEx.repository.CategoryRepository;
import com.abc.SpringBootSecqurityEx.repository.ProductImageRepository;
import com.abc.SpringBootSecqurityEx.repository.ProductRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final BrandRepository brandRepository;
    private final CategoryRepository categoryRepository;
    private final ProductImageRepository productImageRepository;
    private final FileUploadService fileUploadService;

    /* ================= CREATE ================= */
    public ProductResponseDTO create(ProductRequestDTO dto, List<MultipartFile> images) {

        Product product = new Product();
        mapDtoToEntity(dto, product);

        Product savedProduct = productRepository.save(product);

        saveImages(savedProduct, images);

        return mapEntityToDto(savedProduct);
    }

    /* ================= UPDATE ================= */
    public ProductResponseDTO update(Long id, ProductRequestDTO dto, List<MultipartFile> images) {

        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        mapDtoToEntity(dto, product);

        if (images != null && !images.isEmpty()) {
            product.getImages().clear();
            saveImages(product, images);
        }

        return mapEntityToDto(productRepository.save(product));
    }

    /* ================= GET ALL ================= */
    public List<ProductResponseDTO> getAll() {
        return productRepository.findAll()
                .stream()
                .map(this::mapEntityToDto)
                .toList();
    }

    /* ================= GET BY ID ================= */
    public ProductResponseDTO getById(Long id) {
        return productRepository.findById(id)
                .map(this::mapEntityToDto)
                .orElseThrow(() -> new RuntimeException("Product not found"));
    }

    /* ================= DELETE ================= */
    public void delete(Long id) {
        productRepository.deleteById(id);
    }

    /* ================= IMAGE HANDLING ================= */
    private void saveImages(Product product, List<MultipartFile> images) {
        if (images == null) return;

        for (int i = 0; i < images.size(); i++) {
            MultipartFile file = images.get(i);
            String imageUrl = fileUploadService.upload(file);

            ProductImage image = new ProductImage();
            image.setImageUrl(imageUrl);
            image.setPrimaryImage(i == 0);
            image.setProduct(product);

            productImageRepository.save(image);
        }
    }

    /* ================= MAPPING ================= */
    private void mapDtoToEntity(ProductRequestDTO dto, Product product) {

        product.setName(dto.getName());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setDiscountPrice(dto.getDiscountPrice());
        product.setSku(dto.getSku());
        product.setStockQuantity(dto.getStockQuantity());
        product.setActive(true);

        if (dto.getBrandId() != null) {
            Brand brand = brandRepository.findById(dto.getBrandId())
                    .orElseThrow(() -> new RuntimeException("Brand not found"));
            product.setBrand(brand);
        }

        if (dto.getCategoryIds() != null) {
            Set<Category> categories = dto.getCategoryIds()
                    .stream()
                    .map(id -> categoryRepository.findById(id)
                            .orElseThrow(() -> new RuntimeException("Category not found")))
                    .collect(Collectors.toSet());
            product.setCategories(categories);
        }
    }

    private ProductResponseDTO mapEntityToDto(Product product) {

        return ProductResponseDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .discountPrice(product.getDiscountPrice())
                .active(product.getActive())
                .sku(product.getSku())
                .stockQuantity(product.getStockQuantity())
                .brandName(product.getBrand() != null ? product.getBrand().getName() : null)
                .categories(product.getCategories() != null
                        ? product.getCategories().stream().map(Category::getName).collect(Collectors.toSet())
                        : Set.of())
                .images(product.getImages() != null
                        ? product.getImages().stream().map(ProductImage::getImageUrl).toList()
                        : List.of())
                .createdAt(product.getCreatedAt())
                .build();
    }


    public List<ProductResponseDTO> getByBrandId(Long brandId) {
        return productRepository.findByBrandId(brandId)
                .stream()
                .map(this::mapEntityToDto)  // ঠিক করা হয়েছে
                .toList();
    }
}
