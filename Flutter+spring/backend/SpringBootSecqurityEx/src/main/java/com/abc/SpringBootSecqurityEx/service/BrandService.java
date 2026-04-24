package com.abc.SpringBootSecqurityEx.service;

import com.abc.SpringBootSecqurityEx.dtos.BrandDTO;
import com.abc.SpringBootSecqurityEx.entity.Brand;
import com.abc.SpringBootSecqurityEx.repository.BrandRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class BrandService {

    private final BrandRepository brandRepository;
    private final FileUploadService fileUploadService;

    /* ===================== CREATE ===================== */
    public BrandDTO create(BrandDTO dto, MultipartFile logo) {

        Brand brand = new Brand();
        brand.setName(dto.getName());
        brand.setDescription(dto.getDescription());

        if (logo != null && !logo.isEmpty()) {
            brand.setLogoUrl(fileUploadService.upload(logo));
        }

        brandRepository.save(brand);

        return new BrandDTO(
                brand.getId(),
                brand.getName(),
                brand.getDescription(),
                brand.getLogoUrl()
        );
    }

    /* ===================== READ ALL ===================== */
    public List<BrandDTO> getAll() {
        return brandRepository.findAll()
                .stream()
                .map(b -> new BrandDTO(b.getId(), b.getName(),b.getDescription(), b.getLogoUrl()))
                .toList();
    }

    /* ===================== READ BY ID ===================== */
    public BrandDTO getById(Long id) {

        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Brand not found with id: " + id));

        return new BrandDTO(
                brand.getId(),
                brand.getName(),
                brand.getDescription(),
                brand.getLogoUrl()
        );
    }

    /* ===================== UPDATE ===================== */
    public BrandDTO update(Long id, BrandDTO dto, MultipartFile logo) {

        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Brand not found with id: " + id));

        brand.setName(dto.getName());

        if (logo != null && !logo.isEmpty()) {
            brand.setLogoUrl(fileUploadService.upload(logo));
        }

        brandRepository.save(brand);

        return new BrandDTO(
                brand.getId(),
                brand.getName(),
                brand.getDescription(),
                brand.getLogoUrl()
        );
    }

    /* ===================== DELETE ===================== */
    public void delete(Long id) {

        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Brand not found with id: " + id));

        brandRepository.delete(brand);
    }
}
