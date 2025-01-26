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
│   │   │   └── users.py
│   │   │-- __init__.py
│   │   └── db.py
│   └── __init__.py
│-- .gitignore
│-- alembic.ini
│-- example.env
│-- README.md
└── requirements.txt
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

### 1. Clone the Repository and Setup the Environment

Clone the repository:

```bash
git clone https://github.com/BradleyParkerDev/sqlalchemy_and_alembic_boilerplate.git
```

Navigate into the root directory:
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
DATABASE_URL=postgresql://user:password@localhost:5432/your_database
```

### 4. Run your First Migration

To add new tables or modify existing ones, run:

```bash
alembic revision --autogenerate -m "Your migration message"
```

```bash
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

## Database Object
Located in `app/database/db.py`:

```python
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from .models import Base, UserSession, User

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
        self.engine = create_engine(self.database_url,echo=True)
        self.session_local = sessionmaker(bind=self.engine)
        self.session = self.session_local()

    def close(self):
        if self.session:
            self.session.close

# For db creation without alembic
engine = create_engine(DATABASE_URL, echo=True)
def init_db():
    print("Connecting to database...")
    Base.metadata.create_all(bind=engine)
    print("App successfully connected to database!!!")
```
## Alembic Commands Reference

| Command                      | Description                                |
|------------------------------|--------------------------------------------|
| `alembic revision --autogenerate -m "message"` | Generate a new migration based on changes |
| `alembic upgrade head`        | Apply all pending migrations               |
| `alembic downgrade -1`        | Revert the last migration                  |

## License

This project is intended for personal and educational purposes only.

