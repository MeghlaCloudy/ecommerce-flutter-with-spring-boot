package com.abc.SpringBootSecqurityEx.repository;

import com.abc.SpringBootSecqurityEx.entity.Address;
import com.abc.SpringBootSecqurityEx.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AddressRepository extends JpaRepository<Address, Long> {

    // লগইন করা ইউজারের সব অ্যাড্রেস পাওয়ার জন্য
    List<Address> findByUser(User user);

    // অর্ডারে ব্যবহারের জন্য (যাচাই করবে অ্যাড্রেসটা ইউজারের কিনা)
    Optional<Address> findByIdAndUser(Long id, User user);
}