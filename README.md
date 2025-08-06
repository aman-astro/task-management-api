# Task Management API

A Ruby on Rails API-only application for managing projects, tasks, and comments with secure user authentication and robust authorization.

## Setup Instructions

1. **Clone the repository:**
   ```sh
   git clone git@github.com:aman-astro/task-management-api.git
   cd task-management-api
   ```

2. **Install dependencies:**
   ```sh
   bundle install
   ```

3. **Configure environment variables:**
   Create a `.env` file in the project root with the following variables:
   ```env
   DATABASE_USERNAME=your_db_username
   DATABASE_PASSWORD=your_db_password
   DATABASE_HOST=localhost
   DATABASE_PORT=5432
   DATABASE_NAME=your_db_name
   GMAIL_USER=your_gmail_address
   GMAIL_PASSWORD=your_gmail_app_password
   ```

4. **Set up the database:**
   ```sh
   rails db:create db:migrate
   ```

5. **Run the test suite:**
   ```sh
   bundle exec rspec
   ```

6. **Start the Rails server:**
   ```sh
   rails server
   ```

## Implemented Features

- **User Authentication**
  - Register and log in using email + password
  - Token-based authentication (JWT) for all API requests
- **Password Reset (via OTP)**
  - Users can request a password reset OTP via email
  - Users can reset their password using the OTP
  - **Sidekiq** is used to send the OTP email asynchronously when forgot password is triggered
- **Projects**
  - Create, view, update, and delete projects
  - Each project has a title and description
- **Tasks**
  - Each project can have multiple tasks
  - Task attributes: `title`, `description`, `due_date`, `status` (`pending`, `in_progress`, `completed`)
  - Soft deletion of tasks (using a `deleted_at` column)
  - Pagination and filtering by status and due_date
- **Comments**
  - Each task can have multiple comments
  - Each comment belongs to a user
- **Basic Authorization**
  - Users can only access their own projects, tasks, and comments
- **Validations and Associations** for all models
- **Serializers** for clean JSON responses (ActiveModel::Serializer)
- **Error Handling** for invalid requests
- **RSpec Tests** for models and controllers

---

For API usage and details, see the documentation in the `docs/` directory, which includes:
- `API_DOCS.md` for detailed API documentation
- `Task Management APIs.postman_collection.json` for a ready-to-use Postman collection
