# Classic-ASP
# User Management System - Classic ASP

This is a user management system built using Classic ASP and MySQL. It allows for the creation, update, retrieval, and deletion of user records. The system supports role-based access and allows users to upload profile pictures. The data is stored in a MySQL database.

## Features

- **User Registration**: Allows new users to be added to the system.
- **User Management**: Admins can view, update, and delete users.
- **Role Assignment**: Assign roles to users from a predefined set of roles.
- **Profile Picture Upload**: Users can upload their profile pictures.
- **Password Handling**: Passwords are hashed before being stored in the database.
- **User Activation/Deactivation**: Toggle user status (Active/Inactive).

## Prerequisites

To run this project, you need the following:

- A **web server** that supports Classic ASP (e.g., IIS).
- **MySQL** database server.
- **ADODB** for database connections (built-in with Classic ASP).

## Database Structure

The system uses the following tables:

### `users` table

| Field      | Type         | Description                         |
|------------|--------------|-------------------------------------|
| id         | INT          | Primary key, auto-incremented       |
| name       | VARCHAR(255)  | User's name                         |
| email      | VARCHAR(255)  | User's email                        |
| password   | VARCHAR(255)  | Hashed password                     |
| phone      | VARCHAR(255)  | User's phone number                 |
| picture    | VARCHAR(255)  | Path to the user's profile picture  |
| status     | INT          | 1 for Active, 0 for Inactive        |
| is_default | INT          | 0 for regular users, 1 for default  |

### `roles` table

| Field      | Type         | Description                         |
|------------|--------------|-------------------------------------|
| id         | INT          | Primary key, auto-incremented       |
| name       | VARCHAR(255)  | Name of the role                    |
| is_default | INT          | 0 if not a default role, 1 if default|

### `users_roles` table

| Field      | Type         | Description                         |
|------------|--------------|-------------------------------------|
| user_id    | INT          | Foreign key to `users` table        |
| role_id    | INT          | Foreign key to `roles` table        |

## Installation

### Step 1: Set up the MySQL Database

1. Create a new MySQL database (e.g., `user_management`).
---

## Database Schema

### Tables Overview

1. **Users** (`users`)  
   - Stores user information (name, email, password, status, etc.).

2. **Roles** (`roles`)  
   - Defines roles for users (e.g., Admin, Editor, Viewer).

3. **Modules** (`modules`)  
   - Represents application modules (e.g., Dashboard, Users, Roles).

4. **Rights** (`rights`)  
   - Lists rights (view, add, edit, delete) available for each module.

5. **Role-Module Permissions** (`roles_modules_permissions`)  
   - Links roles to modules with permissions.

6. **Role-Permission Rights** (`roles_modules_permissions_rights`)  
   - Links specific rights to role-module permissions.

---

## Usage

### User Management
1. **Add User**: Navigate to `Users > Add User`.
2. **Edit User**: Click "Edit" in the user listing.
3. **Delete User**: Click "Delete" (if you have the delete right).

### Role Management
1. **Add Role**: Navigate to `Roles > Add Role`. Assign permissions hierarchically.
2. **Edit Role**: Modify role details and permissions.
3. **Delete Role**: Remove roles (restricted if associated with users).

### Rights Management
- Permissions are assigned during role creation/editing in a hierarchical view (Modules → Rights).

---

## Directory Structure

```
user-management-system/
├── common/
│   ├── dbconnections.asp       # Database connection
│   ├── helpers.asp             # Utility functions
│   ├── middleware.asp          # Authentication middleware
├── uploads/
│   └── images/
│       └── profile/            # User profile pictures
├── users/
│   ├── users_add.asp           # Add user
│   ├── users_edit.asp          # Edit user
│   ├── users_delete.asp        # Delete user
│   ├── users_detail.asp        # View user details
│   ├── users_listing.asp       # List users
├── roles/
│   ├── roles_add.asp           # Add role
│   ├── roles_edit.asp          # Edit role
│   ├── roles_delete.asp        # Delete role
│   ├── roles_detail.asp        # View role details
│   ├── roles_listing.asp       # List roles
├── index.asp                   # Dashboard
└── README.md                   # Documentation
```

---

## Helper Functions

**Rights Checking**
```php
hasAddRight($userId, $moduleId, $pdo);
hasEditRight($userId, $moduleId, $pdo);
hasDeleteRight($userId, $moduleId, $pdo);
```

**Folder Management**
```asp
createFolderIfNotExists($path);
```

**Validation**
```asp
isValidEmail($email);
isValidPhoneNumber($phone);
```

---

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new feature branch.
3. Submit a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).
