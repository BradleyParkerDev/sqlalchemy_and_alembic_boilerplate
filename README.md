SQLAlchemy & Alembic Boilerplate
=================================

This repository provides a boilerplate setup for integrating **SQLAlchemy** and **Alembic** in a FastAPI or Python-based backend project. It includes a pre-configured database schema with `User` and `UserSession` tables using PostgreSQL.

## Project Structure

```
sqlalchemy_and_alembic_boilerplate/
│-- app/
│   │-- __pycache__/
│   │-- database/
│   │   │-- __pycache__/
│   │   │-- alembic/
│   │   │-- models/
│   │   │   │-- __pycache__/
│   │   │   │-- __init__.py
│   │   │   │-- model_base_class.py
│   │   │   │-- user_sessions.py
│   │   │   │-- users.py
│   │   │-- __init__.py
│   │   │-- db.py
│   │-- __init__.py
│-- .gitignore
│-- README.md
│-- alembic.ini
└── requirements.txt
```

## Features

- **PostgreSQL Support:** Designed for use with PostgreSQL.
- **SQLAlchemy ORM:** Provides ORM models and database session management.
- **Alembic Migrations:** Database versioning with migration scripts.
- **User and Session Models:** Predefined user and session tables for authentication systems.

## Prerequisites

Ensure you have the following installed before proceeding:

- **Python 3.12.6 or greater**
- **pip 24.2 or greater**

## Setup Instructions

### 1. Clone the Repository and Setup the Environment

Clone the repository:

```bash
git clone https://github.com/BradleyParkerDev/sqlalchemy_and_alembic_boilerplate.git
```

Navigate into the directory:
```bash
cd sqlalchemy_and_alembic_boilerplate
```

Create a virtual environment:
```bash
python -m venv venv
```

Activate the virtual environment:
```bash
source ./venv/bin/activate   # On Windows use `venv\Scripts\activate`
```

### 2. Install Dependencies

Ensure you have Python installed, then install the required dependencies:

```bash
pip install -r requirements.txt
```

### 3. Configure Database

Create a `.env` file:

```bash
touch .env
```

Then add your `DATABASE_URL` to it:
```bash
DATABASE_URL =postgresql://user:password@localhost:5432/your_database
```

### 4. Run Database Migrations

Initialize and upgrade your database schema using Alembic:

```bash
alembic upgrade head
```

### 5. Running the Application

You can now integrate this boilerplate into your FastAPI or Flask application and start making CRUD operations.

### 6. Creating Migrations

To add new tables or modify existing ones, run:

```bash
alembic revision --autogenerate -m "Your migration message"
alembic upgrade head
```

## Database Models

### `User` Model
Located in `app/database/models/users.py`:

```python
import uuid
from .model_base_class import Base
from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID as pgUUID
from datetime import datetime, timezone 

class User(Base):
    __tablename__ = "users"

    user_id = Column(pgUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_image = Column(String, nullable=False)
    user_name = Column(String, unique=True, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    email_address = Column(String, nullable=False)
    password = Column(String, unique=True, nullable=False)
    last_updated = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
```

### `UserSession` Model
Located in `app/database/models/user_sessions.py`:

```python
import uuid
from .model_base_class import Base
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as pgUUID
from datetime import datetime, timezone, timedelta 

class UserSession(Base):
    __tablename__ = "user_sessions"

    session_id = Column(pgUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(pgUUID(as_uuid=True), ForeignKey('users.user_id',ondelete="CASCADE"), nullable=True)
    start_time = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    expiration_time = Column(DateTime, default=lambda: datetime.now(timezone.utc) + timedelta(days=7))

    @staticmethod
    def get_expiration_time():
        return datetime.now(timezone.utc) + timedelta(days=7)
```

## Alembic Commands Reference

| Command                      | Description                                |
|------------------------------|--------------------------------------------|
| `alembic init alembic`        | Initialize Alembic directory               |
| `alembic revision --autogenerate -m "message"` | Generate a new migration based on changes |
| `alembic upgrade head`        | Apply all pending migrations               |
| `alembic downgrade -1`        | Revert the last migration                  |


## License

This project is intended for personal and educational purposes only.

