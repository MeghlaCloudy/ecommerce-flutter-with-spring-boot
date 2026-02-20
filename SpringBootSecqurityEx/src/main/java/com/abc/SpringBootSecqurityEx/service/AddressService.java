package com.abc.SpringBootSecqurityEx.service;

import com.abc.SpringBootSecqurityEx.entity.Address;
import com.abc.SpringBootSecqurityEx.entity.User;
import com.abc.SpringBootSecqurityEx.repository.AddressRepository;
import com.abc.SpringBootSecqurityEx.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AddressService {

    private final AddressRepository addressRepository;
    private final UserRepository userRepository;

    private User getCurrentUser() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findById(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    // ইউজারের সব অ্যাড্রেস দেখা
    public List<Address> getUserAddresses() {
        User user = getCurrentUser();
        return addressRepository.findByUser(user);
    }

    // নতুন অ্যাড্রেস অ্যাড করা
    public Address addAddress(Address address) {
        User user = getCurrentUser();
        address.setUser(user);
        return addressRepository.save(address);
    }
}