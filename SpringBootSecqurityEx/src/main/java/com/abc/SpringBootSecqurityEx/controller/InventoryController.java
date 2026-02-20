package com.abc.SpringBootSecqurityEx.controller;


import com.abc.SpringBootSecqurityEx.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    @PutMapping("/{productId}")
    public ResponseEntity<Void> updateStock(
            @PathVariable Long productId,
            @RequestParam Integer quantity) {

        inventoryService.updateStock(productId, quantity);
        return ResponseEntity.ok().build();
    }
}
