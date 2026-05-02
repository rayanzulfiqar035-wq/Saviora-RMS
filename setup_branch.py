import os
from app import create_app
from models import db, DiningTable, Staff, Branch, Role
from sqlalchemy import text

app = create_app()

def setup_single_branch():
    with app.app_context():
        # 1. Clear existing data to avoid conflicts (Staff and Tables)
        # Disable FK checks to truncate
        db.session.execute(text("SET FOREIGN_KEY_CHECKS = 0;"))
        db.session.execute(text("DELETE FROM STAFF;"))
        db.session.execute(text("DELETE FROM DINING_TABLE;"))
        db.session.execute(text("DELETE FROM Branch;"))
        
        # 2. Ensure Branch 1 exists
        main_branch = Branch(branch_id=1, name="Saviora Main Branch", location="Blue Area, Islamabad", phone_number="051-1234567")
        db.session.add(main_branch)
        
        # 3. Add 25 Dining Tables for Branch 1
        for i in range(1, 26):
            table = DiningTable(
                table_id=i,
                branch_id=1,
                table_number=i,
                seating_capacity=2 if i % 3 == 0 else 4, # Mix of 2 and 4 seats
                table_state='Available'
            )
            db.session.add(table)
        
        # Add the Virtual Table for Takeaway
        virtual_table = DiningTable(
            table_id=999,
            branch_id=1,
            table_number=0,
            seating_capacity=0,
            table_state='Virtual'
        )
        db.session.add(virtual_table)
        
        # 4. Add 10 Staff Members for Branch 1
        # 1 Admin (Role 1)
        admin = Staff(
            staff_id=1,
            branch_id=1,
            role_id=1,
            username="admin",
            password_hash="admin123",
            first_name="Admin"
        )
        db.session.add(admin)
        
        # 9 Waiters (Role 5)
        for i in range(2, 11):
            waiter = Staff(
                staff_id=i,
                branch_id=1,
                role_id=5,
                username=f"waiter{i-1}",
                password_hash=f"waiter{i-1}",
                first_name=f"Waiter {i-1}"
            )
            db.session.add(waiter)
            
        db.session.execute(text("SET FOREIGN_KEY_CHECKS = 1;"))
        db.session.commit()
        print("Successfully configured Branch 1 with 25 tables and 10 staff members.")

if __name__ == "__main__":
    setup_single_branch()
