package com.abc.SpringBootSecqurityEx.service;


import com.abc.SpringBootSecqurityEx.entity.Inventory;
import com.abc.SpringBootSecqurityEx.entity.Product;
import com.abc.SpringBootSecqurityEx.repository.InventoryRepository;
import com.abc.SpringBootSecqurityEx.repository.ProductRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
@Service
@RequiredArgsConstructor
@Transactional
public class InventoryService {

    private final InventoryRepository inventoryRepository;
    private final ProductRepository productRepository;

    public void updateStock(Long productId, Integer quantity) {

        Inventory inventory = inventoryRepository.findByProductId(productId)
                .orElseGet(() -> {
                    Inventory inv = new Inventory();
                    Product product = productRepository.findById(productId)
                            .orElseThrow(() -> new RuntimeException("Product not found"));
                    inv.setProduct(product);
                    return inv;
                });

        inventory.setAvailableQuantity(quantity);
        inventoryRepository.save(inventory);
    }
}
