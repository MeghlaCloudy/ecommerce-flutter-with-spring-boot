package com.abc.SpringBootSecqurityEx.repository;

import com.abc.SpringBootSecqurityEx.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    // ব্র্যান্ড আইডি দিয়ে প্রোডাক্ট লোড করার মেথড
    List<Product> findByBrandId(Long brandId);

    // অপশনাল: ক্যাটাগরি দিয়েও ফিল্টার করতে চাইলে
    // List<Product> findByCategoryId(Long categoryId);
}