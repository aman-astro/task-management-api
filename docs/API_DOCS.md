# API Documentation

---

## Authentication (Registration & Login)

### Register
- **POST** `/api/register`
- **Body:**
  ```json
  {
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "password123"
    }
  }
  ```
- **Response:** 201 Created, user info + JWT token

### Login
- **POST** `/api/login`
- **Body:**
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- **Response:** 200 OK, user info + JWT token

---

## Password Reset

### Forgot Password (Request OTP)
- **POST** `/api/v1/users/forgot_password`
- **Body:**
  ```json
  {
    "user_email": "user@example.com"
  }
  ```
- **Response:**
  - 200 OK, message: "OTP sent to your email" (if user exists)
  - 404 Not Found, message: "User not found" (if email not found)

### Reset Password (Using OTP)
- **POST** `/api/v1/users/reset_password`
- **Body:**
  ```json
  {
    "user_email": "user@example.com",
    "otp": "123456",
    "new_password": "newpassword123",
    "confirm_new_password": "newpassword123"
  }
  ```
- **Response:**
  - 200 OK, message: "Password has been reset successfully"
  - 400 Bad Request, message: "Passwords do not match or are blank"
  - 400 Bad Request, message: "Invalid OTP or OTP expired"
  - 400 Bad Request, message: "Failed to reset password" (with errors)

---

## Projects

### List Projects
- **GET** `/api/v1/projects`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "status": "success",
    "data": [ { ...project... }, ... ],
    "message": "Projects retrieved successfully"
  }
  ```

### Show Project
- **GET** `/api/v1/projects/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "status": "success",
    "data": { ...project... },
    "message": "Project retrieved successfully"
  }
  ```

### Create Project
- **POST** `/api/v1/projects`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "project": {
      "title": "Project Title",
      "description": "Project description"
    }
  }
  ```
- **Response:** 201 Created, project info

### Update Project
- **PUT/PATCH** `/api/v1/projects/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "project": {
      "title": "New Title",
      "description": "New description"
    }
  }
  ```
- **Response:** 200 OK, updated project info

### Delete Project
- **DELETE** `/api/v1/projects/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, success message

---

## Tasks

### List Tasks for a Project
- **GET** `/api/v1/projects/:project_id/tasks`
- **Headers:** `Authorization: Bearer <token>`
- **Query Params:**
  - `page` (optional, default: 1)
  - `per_page` (optional, default: 10)
  - `status` (optional, e.g. `pending,in_progress`)
  - `due_date` (optional, e.g. `2024-08-01`)
- **Response:**
  ```json
  {
    "status": "success",
    "data": {
      "tasks": [ { ...task... }, ... ],
      "pagination": {
        "current_page": 1,
        "total_pages": 2,
        "total_count": 12,
        "per_page": 10
      }
    },
    "message": "Tasks retrieved successfully"
  }
  ```

### List All Tasks for User
- **GET** `/api/v1/tasks/all`
- **Headers:** `Authorization: Bearer <token>`
- **Query Params:** same as above
- **Response:** same as above

### Show Task
- **GET** `/api/v1/tasks/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, task info

### Create Task
- **POST** `/api/v1/projects/:project_id/tasks`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "task": {
      "title": "Task Title",
      "description": "Task description",
      "due_date": "2024-08-01",
      "status": "pending"
    }
  }
  ```
- **Response:** 201 Created, task info

### Update Task
- **PUT/PATCH** `/api/v1/tasks/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "task": {
      "title": "Updated Title",
      "status": "done"
    }
  }
  ```
- **Response:** 200 OK, updated task info

### Delete Task (Soft Delete)
- **DELETE** `/api/v1/tasks/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, success message

---

## Comments

### List Comments for a Task
- **GET** `/api/v1/comments/task_id/:task_id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, array of comments

### List Comments by User
- **GET** `/api/v1/comments/user_id/:user_id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, array of comments

### Show Comment
- **GET** `/api/v1/comments/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, comment info

### Create Comment
- **POST** `/api/v1/comments`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "comment": {
      "content": "This is a comment",
      "task_id": 1
    }
  }
  ```
- **Response:** 201 Created, comment info

### Update Comment
- **PUT/PATCH** `/api/v1/comments/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "comment": {
      "content": "Updated comment"
    }
  }
  ```
- **Response:** 200 OK, updated comment info

### Delete Comment
- **DELETE** `/api/v1/comments/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:** 200 OK, success message

---

## Users

### Update User (Profile)
- **PUT/PATCH** `/api/v1/users/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "user": {
      "name": "New Name"
    }
  }
  ```
- **Note:** Only the current user can update their own profile. Attempting to update another user will return an unauthorized error.
- **Response:** 200 OK, updated user info

### Delete User (Profile)
- **DELETE** `/api/v1/users/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Note:** Only the current user can delete their own profile. Attempting to delete another user will return an unauthorized error.
- **Response:** 200 OK, success message

---

## General Notes
- All endpoints (except registration/login and password reset) require a valid JWT in the `Authorization` header.
- All resource access is scoped to the authenticated user.
- Error responses are consistent and include a message and status.