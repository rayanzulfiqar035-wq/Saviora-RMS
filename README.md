# Saviora RMS 🍽️
**Savor the Efficiency. Manage the Excellence.**

Saviora is a high-performance, enterprise-grade Restaurant Management System (RMS) built with **Python Flask** and **MySQL**. It is designed to handle multi-branch operations with a focus on speed, security, and premium user experience.

---

## 🚀 Key Features

### 🏢 Multi-Branch Architecture
- **Data Isolation**: Each branch manages its own staff, tables, and inventory.
- **Branch Dashboard**: Real-time metrics for today's orders, revenue, and stock levels.

### 🔐 Enterprise Security & RBAC
- **Role-Based Access Control**: Custom permissions for Admins, Managers, Waiters, Chefs, and Cashiers.
- **Secure Authentication**: Hashed passwords and session-based branch locking.

### 📦 Advanced Inventory Management
- **DB-Side Logic**: Low-stock alerts and item counts are calculated directly in the database for maximum performance.
- **Recipe Integration**: Stock is automatically deducted when an order is completed.

### 🍱 Dynamic Ordering System
- **Dine-In & Takeaway**: Support for physical tables and virtual takeaway "tables."
- **Ingredient Substitution**: Advanced logic for swapping ingredients (e.g., Mutton to Chicken) with automated price adjustments.
- **Kitchen Display (KDS)**: Real-time order tracking for chefs.

### 💎 Customer Loyalty
- **Automated Points**: Customers earn points on every purchase.
- **Reward Tiers**: Dynamic tier upgrades (Starter → Silver → Gold) based on total points.

---

## 🛠️ Tech Stack
- **Backend**: Python (Flask)
- **Database**: MySQL (8.0+)
- **ORM**: SQLAlchemy
- **Frontend**: HTML5, CSS3 (Vanilla), Bootstrap 5, Bi-Icons
- **Design**: Premium Glassmorphism UI

---

## 📥 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/rayanzulfiqar035-wq/Saviora-RMS.git
cd Saviora-RMS
```

### 2. Setup Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Database Configuration
1. Create a MySQL database named `Restaurant_db`.
2. Import the master script:
```bash
mysql -u your_username -p Restaurant_db < saviora_master_setup.sql
```

### 4. Run the Application
```bash
python app.py
```
Access the app at `http://127.0.0.1:5000`

---

## 📊 Database Architecture
The system uses a highly optimized schema with:
- **Triggers**: For automated subtotal and loyalty point calculations.
- **Stored Functions**: `GetTodayOrderCount`, `GetBranchLowStockCount`, etc.
- **Procedures**: `CompleteOrderAndDeductStock` for atomic transaction handling.

---

## 📜 License
This project is for educational and commercial management use. 

