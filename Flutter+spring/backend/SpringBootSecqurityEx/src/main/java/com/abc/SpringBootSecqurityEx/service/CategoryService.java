package com.abc.SpringBootSecqurityEx.service;

import com.abc.SpringBootSecqurityEx.dtos.CategoryDTO;
import com.abc.SpringBootSecqurityEx.entity.Category;
import com.abc.SpringBootSecqurityEx.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final FileUploadService fileUploadService;

    /* ================= CREATE ================= */
    public CategoryDTO create(CategoryDTO dto, MultipartFile image) {

        Category category = new Category();
        mapDtoToEntity(dto, category);

        if (image != null && !image.isEmpty()) {
            category.setImageUrl(fileUploadService.upload(image));
        }

        return mapEntityToDto(categoryRepository.save(category));
    }

    /* ================= UPDATE ================= */
    public CategoryDTO update(Long id, CategoryDTO dto, MultipartFile image) {

        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        mapDtoToEntity(dto, category);

        if (image != null && !image.isEmpty()) {
            category.setImageUrl(fileUploadService.upload(image));
        }

        return mapEntityToDto(categoryRepository.save(category));
    }

    /* ================= GET ALL ================= */
    public List<CategoryDTO> getAll() {
        return categoryRepository.findAll()
                .stream()
                .map(this::mapEntityToDto)
                .collect(Collectors.toList());
    }

    /* ================= GET BY ID ================= */
    public CategoryDTO getById(Long id) {
        return categoryRepository.findById(id)
                .map(this::mapEntityToDto)
                .orElseThrow(() -> new RuntimeException("Category not found"));
    }

    /* ================= DELETE ================= */
    public void delete(Long id) {
        categoryRepository.deleteById(id);
    }

    /* ================= MAPPERS ================= */
    private void mapDtoToEntity(CategoryDTO dto, Category entity) {
        entity.setName(dto.getName());

        if (dto.getParentId() != null) {
            Category parent = categoryRepository.findById(dto.getParentId())
                    .orElseThrow(() -> new RuntimeException("Parent category not found"));
            entity.setParent(parent);
        } else {
            entity.setParent(null);
        }
    }

    private CategoryDTO mapEntityToDto(Category entity) {
        return new CategoryDTO(
                entity.getId(),
                entity.getName(),
                entity.getImageUrl(),
                entity.getParent() != null ? entity.getParent().getId() : null
        );
    }
}
