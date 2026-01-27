# SQLAlchemy & Alembic Boilerplate

This repository provides a boilerplate setup for integrating **SQLAlchemy** and **Alembic** in a FastAPI or Python-based backend project. It includes a pre-configured database schema with `User` and `UserSession` tables using PostgreSQL.

## Project Structure

```
sqlalchemy_and_alembic_boilerplate/
├── app/                                 # Main application folder
│   ├── __pycache__/                     # Compiled Python bytecode files
│   ├── database/                        # Database-related files and folders
│   │   ├── __pycache__/                 # Compiled bytecode for database files
│   │   ├── alembic/                     # Alembic migration folder (auto-generated)
│   │   ├── models/                      # Database models live here
│   │   │   ├── __pycache__/             # Compiled bytecode for models
│   │   │   ├── __init__.py              # Makes 'models' folder a Python package
│   │   │   ├── model_base_class.py      # Base SQLAlchemy model class
│   │   │   ├── user_sessions.py         # User sessions table definition
│   │   │   └── users.py                 # Users table definition
│   │   ├── __init__.py                  # Makes 'database' a package
│   │   └── db.py                        # Database connection setup (engine, session, etc.)
│   ├── __init__.py                      # Makes 'app' a Python package
├── .gitignore                           # Files and folders to ignore in git
├── alembic.ini                          # Alembic configuration file
├── example.env                          # Example environment variable file
├── README.md                            # Project documentation
└── requirements.txt                     # Python dependencies list

```

## Features

- **PostgreSQL Support:** Designed for use with PostgreSQL.
- **SQLAlchemy ORM:** Provides ORM models and database session management.
- **Alembic Migrations:** Database versioning with migration scripts.
- **User and Session Models:** Predefined user and session tables for authentication systems.

## Prerequisites

Ensure you have the following installed before proceeding:

- **Python 3.13.1 or greater**
- **pip 25 or greater**

## Setup Instructions

### 1. Clone the Repository

Clone the repository:

```bash
git clone https://github.com/BradleyParkerDev/sqlalchemy_and_alembic_boilerplate.git
```

Navigate into the root directory:

```bash
cd sqlalchemy_and_alembic_boilerplate
```

### 2. Create a Virtual Environment

Create a virtual environment:

```bash
python -m venv venv
```

or use make:

```bash
make env
```

Activate the virtual environment:

```bash
source ./venv/bin/activate   # On Windows use `venv\Scripts\activate`
```

### 3. Install Dependencies

Ensure you have Python installed, then install the required dependencies:

```bash
pip install -e .[dev]
```

or use make:

```bash
make install
```

### 4. Configure Database

Create a `.env` file:

```bash
touch .env
```

Then add your `DATABASE_URL` to it:

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/your_database
```

### 5. Run your First Migration

To add new tables or modify existing ones, run:

```bash
alembic revision --autogenerate -m "Your migration message"
```

or use make:

```bash
make db-revision MSG="Your migration message"
```

```bash
alembic upgrade head
```

or use make:

```bash
make db-up
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

## Database Object

Located in `app/database/db.py`:

```python
import os
import logging
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database.models import Base, UserSession, User


# Disable SQLAlchemy INFO logs but keep warnings/errors
logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)  # Suppresses SQL execution logs (e.g., SELECT, INSERT)
logging.getLogger("sqlalchemy.orm").setLevel(logging.WARNING)  # Hides ORM-related logs (e.g., session commits, queries)
logging.getLogger("sqlalchemy.pool").setLevel(logging.WARNING)  # Prevents logs about database connections (pooling)
logging.getLogger("sqlalchemy").setLevel(logging.WARNING)  # Disables all SQLAlchemy logs except warnings/errors

# Load environment variables
load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

# For CRUD operations
class DB:
    def __init__(self):
        self.database_url = DATABASE_URL
        self.session_local = None
        self.session = None

    def initialize(self):
        self.engine = create_engine(self.database_url,echo=False) # echo=False suppresses SQL logs
        self.session_local = sessionmaker(bind=self.engine)
        self.session = self.session_local()

    def close(self):
        if self.session:
            self.session.close()

# For db creation without alembic
engine = create_engine(DATABASE_URL, echo=False) # echo=False suppresses SQL logs
def init_db():
    print("Connecting to database...")
    Base.metadata.create_all(bind=engine)
    print("App successfully connected to database!!!")
```

## Scripts

### Make Commands

```bash
make env            # Create a virtual environment
make clean          # Remove build artifacts and caches
make install        # Python dev deps
make freeze         # Export Python deps to requirements.txt
make db-revision    # Create alembic migration (use MSG="message")
make db-up          # Apply all pending migrations
make db-down        # Revert the last migration
```

## Alembic Commands Reference

| Command                                        | Description                               |
| ---------------------------------------------- | ----------------------------------------- |
| `alembic revision --autogenerate -m "message"` | Generate a new migration based on changes |
| `alembic upgrade head`                         | Apply all pending migrations              |
| `alembic downgrade -1`                         | Revert the last migration                 |

**Note:** For guidance on editing migration files, see the Alembic documentation.

## Development Notes

Ensure that your PostgreSQL database timezone is set to 'UTC' (Coordinated Universal Time) in your PostgreSQL configuration. This helps avoid timezone-related issues and ensures consistency across different environments.

If you are using Neon, note that it uses 'GMT' (Greenwich Mean Time) by default, which is functionally equivalent to UTC+0. No additional configuration is needed for Neon, but you should still verify your database settings if working across multiple environments.

## License

This project is intended for personal and educational purposes only.
