enum UserRole { customer, vendor, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final bool isActive;
  final String profileImage;
  final String address;
  final DateTime createdAt;
  // Vendor fields
  final String? restaurantName;
  final String? restaurantDescription;
  final double? restaurantRating;
  final bool? isApproved;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.isActive = true,
    this.profileImage = 'assets/images/profile.jpeg',
    this.address = '',
    DateTime? createdAt,
    this.restaurantName,
    this.restaurantDescription,
    this.restaurantRating,
    this.isApproved,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    UserRole? role,
    bool? isActive,
    String? profileImage,
    String? address,
    DateTime? createdAt,
    String? restaurantName,
    String? restaurantDescription,
    double? restaurantRating,
    bool? isApproved,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantDescription:
          restaurantDescription ?? this.restaurantDescription,
      restaurantRating: restaurantRating ?? this.restaurantRating,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.toString().split('.').last,
        'isActive': isActive,
        'profileImage': profileImage,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
        'restaurantName': restaurantName,
        'restaurantDescription': restaurantDescription,
        'restaurantRating': restaurantRating,
        'isApproved': isApproved,
      };

  factory UserModel.fromMap(Map<String, dynamic> m) {
    UserRole parseRole(String? s) {
      switch (s) {
        case 'vendor':
          return UserRole.vendor;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.customer;
      }
    }

    return UserModel(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      phone: m['phone'] ?? '',
      password: m['password'] ?? '',
      role: parseRole(m['role']?.toString()),
      isActive: m['isActive'] ?? true,
      profileImage: m['profileImage'] ?? 'assets/images/profile.jpeg',
      address: m['address'] ?? '',
      createdAt: m['createdAt'] != null
          ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      restaurantName: m['restaurantName'],
      restaurantDescription: m['restaurantDescription'],
      restaurantRating: (m['restaurantRating'] is num)
          ? (m['restaurantRating'] as num).toDouble()
          : null,
      isApproved: m['isApproved'],
    );
  }
}

extension UserModelSerialization on UserModel {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.toString().split('.').last,
        'isActive': isActive,
        'profileImage': profileImage,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
        'restaurantName': restaurantName,
        'restaurantDescription': restaurantDescription,
        'restaurantRating': restaurantRating,
        'isApproved': isApproved,
      };

  static UserModel fromMap(Map<String, dynamic> m) {
    UserRole parseRole(String? s) {
      switch (s) {
        case 'vendor':
          return UserRole.vendor;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.customer;
      }
    }

    return UserModel(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      phone: m['phone'] ?? '',
      password: m['password'] ?? '',
      role: parseRole(m['role']?.toString()),
      isActive: m['isActive'] ?? true,
      profileImage: m['profileImage'] ?? 'assets/images/profile.jpeg',
      address: m['address'] ?? '',
      createdAt: m['createdAt'] != null
          ? DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      restaurantName: m['restaurantName'],
      restaurantDescription: m['restaurantDescription'],
      restaurantRating: (m['restaurantRating'] is num)
          ? (m['restaurantRating'] as num).toDouble()
          : null,
      isApproved: m['isApproved'],
    );
  }
}
