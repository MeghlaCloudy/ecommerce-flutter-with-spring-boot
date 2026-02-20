package com.abc.SpringBootSecqurityEx.controller;

import com.abc.SpringBootSecqurityEx.entity.Address;
import com.abc.SpringBootSecqurityEx.service.AddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/addresses")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:4200")  // Angular-এর জন্য
public class AddressController {

    private final AddressService addressService;

    // ইউজারের সব অ্যাড্রেস
    @GetMapping
    public List<Address> getUserAddresses() {
        return addressService.getUserAddresses();
    }

    // নতুন অ্যাড্রেস অ্যাড করা
    @PostMapping
    public Address addAddress(@RequestBody Address address) {
        return addressService.addAddress(address);
    }
}