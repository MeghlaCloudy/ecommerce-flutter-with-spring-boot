package com.abc.SpringBootSecqurityEx.dtos.secqurity;

import java.util.Set;

public record RoleUpdateRequest(Set<String> roles) {
}
