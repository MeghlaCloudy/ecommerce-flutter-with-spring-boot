package com.abc.SpringBootSecqurityEx.service;

import com.abc.SpringBootSecqurityEx.dtos.CartDto;
import com.abc.SpringBootSecqurityEx.dtos.CartItemRequest;
import com.abc.SpringBootSecqurityEx.dtos.ItemDto;
import com.abc.SpringBootSecqurityEx.entity.Cart;
import com.abc.SpringBootSecqurityEx.entity.CartItem;
import com.abc.SpringBootSecqurityEx.entity.Product;
import com.abc.SpringBootSecqurityEx.entity.User;
import com.abc.SpringBootSecqurityEx.repository.CartRepository;
import com.abc.SpringBootSecqurityEx.repository.ProductRepository;
import com.abc.SpringBootSecqurityEx.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CartService {

    private final CartRepository cartRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    // Get the current logged-in user using SecurityContextHolder
    private User getCurrentUser() {
        // Extract the username from SecurityContext
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findById(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    // Get the cart of the logged-in user
    public CartDto getCart() {
        User currentUser = getCurrentUser();
        Cart cart = cartRepository.findByUser(currentUser)
                .orElseGet(() -> createNewCartForUser(currentUser)); // Create a new cart if none exists
        cart.calculateTotalAmount(); // Calculate the total amount for the cart
        return mapCartToDto(cart); // Return the updated cart DTO
    }

    // Add an item to the cart of the current user
    public CartDto addItemToCart(CartItemRequest request) {
        User currentUser = getCurrentUser();
        Cart cart = cartRepository.findByUser(currentUser)
                .orElseGet(() -> createNewCartForUser(currentUser));

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Optional<CartItem> existingItem = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(product.getId()))
                .findFirst();

        CartItem cartItem;

        if (existingItem.isEmpty()) {
            // Add a new item if it's not already in the cart
            cartItem = new CartItem();
            cartItem.setProduct(product);
            cartItem.setQuantity(request.getQuantity());
            cartItem.setCart(cart);
            cart.getItems().add(cartItem);
        } else {
            // Update quantity if the product is already in the cart
            cartItem = existingItem.get();
            cartItem.setQuantity(cartItem.getQuantity() + request.getQuantity());
        }

        cart.calculateTotalAmount(); // Recalculate the total amount
        cartRepository.save(cart); // Save the cart with the updated items
        return mapCartToDto(cart);
    }

    // Update a cart item
    public CartDto updateCartItem(Long cartItemId, CartItemRequest request) {
        User currentUser = getCurrentUser();
        Cart cart = cartRepository.findByUser(currentUser)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        CartItem cartItem = cart.getItems().stream()
                .filter(item -> item.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found"));

        cartItem.setQuantity(request.getQuantity()); // Update quantity of the cart item
        cart.calculateTotalAmount(); // Recalculate total amount after update
        cartRepository.save(cart); // Save the updated cart
        return mapCartToDto(cart); // Return the updated cart DTO
    }

    // Remove a cart item
    public void removeCartItem(Long cartItemId) {
        User currentUser = getCurrentUser();
        Cart cart = cartRepository.findByUser(currentUser)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        CartItem cartItem = cart.getItems().stream()
                .filter(item -> item.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found"));

        cartItem.setCart(null);
        cart.getItems().remove(cartItem); // Remove the cart item
        cart.calculateTotalAmount(); // Recalculate total amount after removal
        cartRepository.save(cart); // Save the updated cart
    }

    // Helper method to create a new cart for a user
    private Cart createNewCartForUser(User user) {
        Cart cart = new Cart();
        cart.setUser(user);
        return cartRepository.save(cart);
    }

    private CartDto mapCartToDto(Cart cart) {
        CartDto cartDto = new CartDto();
        cartDto.setCartId(cart.getId());
        cartDto.setTotalAmount(cart.getTotalAmount());

        // Map cart items to ItemDto
        cartDto.setItems(cart.getItems().stream()
                .map(item -> {
                    ItemDto itemDto = new ItemDto();
                    itemDto.setItemId(item.getId());
                    itemDto.setProductId(item.getProduct().getId());
                    try {
                        itemDto.setImageUrl(item.getProduct().getImages().get(0).getImageUrl());
                    } catch (Exception e) {
                        System.out.println("No image found!!");
                    }
                    itemDto.setProductName(item.getProduct().getName());
                    itemDto.setQuantity(item.getQuantity());
                    itemDto.setPrice(item.getProduct().getPrice());
                    itemDto.setTotal(item.getTotalPrice()); // Calculate total price for this cart item
                    return itemDto;
                })
                .collect(Collectors.toList()));

        return cartDto;
    }

    public Cart getCartEntity() {
        User currentUser = getCurrentUser();
        return cartRepository.findByUser(currentUser)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
    }
}
