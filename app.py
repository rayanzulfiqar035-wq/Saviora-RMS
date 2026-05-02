from flask import Flask, render_template, session
from flask_login import LoginManager, login_required
from models import db, DiningTable, InventoryItem, IngredientCatalog, BranchInventory
from sqlalchemy import text
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def create_app():
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'default-dev-key')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Initialize extensions
    db.init_app(app)
    
    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(user_id):
        from models import Staff
        return Staff.query.get(int(user_id))

    # Register Blueprints
    from auth import auth_bp
    from orders import orders_bp
    from billing import billing_bp
    from inventory import inventory_bp
    from reservations import reservations_bp
    from customers import customers_bp
    from reports import reports_bp
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(orders_bp)
    app.register_blueprint(billing_bp)
    app.register_blueprint(inventory_bp)
    app.register_blueprint(reports_bp)
    app.register_blueprint(reservations_bp)
    app.register_blueprint(customers_bp)

    @app.route('/')
    @login_required
    def index():
        branch_id = session.get('branch_id')
        role_id = session.get('role_id')
        
        if role_id == 3: # Waiter
            try:
                active_orders = db.session.execute(
                    text("SELECT * FROM vw_waiter_active_orders WHERE staff_id = :staff_id ORDER BY order_timestamp DESC"),
                    {'staff_id': current_user.staff_id}
                ).mappings().all()
            except Exception as e:
                print(f"Error fetching waiter orders: {e}")
                active_orders = []
            return render_template('waiter_dashboard.html', active_orders=active_orders)
            
        if not branch_id:
            return render_template('index.html', stats={
                'today_orders': 0, 'revenue': 0.0, 'occupied_tables': 0, 'total_tables': 0, 'low_stock_count': 0
            })
        
        # 1. Today's Orders (Using GetTodayOrderCount Function)
        try:
            today_orders = db.session.execute(
                text("SELECT GetTodayOrderCount(:branch_id)"),
                {'branch_id': branch_id}
            ).scalar() or 0
        except Exception as e:
            print(f"Error fetching today orders: {e}")
            today_orders = 0

        # 2. Today's Revenue (Using Function)
        try:
            revenue = db.session.execute(
                text("SELECT GetBranchRevenue(:branch_id, CURDATE())"),
                {'branch_id': branch_id}
            ).scalar() or 0.0
        except Exception as e:
            print(f"Error fetching revenue: {e}")
            revenue = 0.0

        # 3. Active Tables (Occupied / Total Physical Tables)
        try:
            occupied_tables = DiningTable.query.filter_by(branch_id=branch_id, table_state='Occupied').count()
            total_tables = DiningTable.query.filter_by(branch_id=branch_id).filter(DiningTable.table_number > 0).count()
        except Exception as e:
            print(f"Error fetching tables: {e}")
            occupied_tables, total_tables = 0, 0

        # 4. Low Stock Items (Using GetBranchLowStockCount DB Function)
        try:
            low_stock_count = db.session.execute(
                text("SELECT GetBranchLowStockCount(:branch_id)"),
                {'branch_id': branch_id}
            ).scalar() or 0
        except Exception as e:
            print(f"Error fetching low stock: {e}")
            low_stock_count = 0

        stats = {
            'today_orders': today_orders,
            'revenue': float(revenue),
            'occupied_tables': occupied_tables,
            'total_tables': total_tables,
            'low_stock_count': low_stock_count
        }

        return render_template('index.html', stats=stats)

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, port=5000)