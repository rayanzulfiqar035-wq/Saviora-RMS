from flask import Blueprint, render_template, session, flash, redirect, url_for
from flask_login import login_required
from models import db, Order, OrderItem, MenuItem, Staff
from sqlalchemy import text, func
from datetime import date

reports_bp = Blueprint('reports', __name__, url_prefix='/reports')

@reports_bp.route('/')
@login_required
def dashboard():
    # Only Admin can see Reports in the new 2-role system
    # Manager and Assistant Manager can see Reports
    if session.get('role_id') not in [1, 2]:
        flash("You do not have permission to view reports.", "danger")
        return redirect(url_for('index'))
        
    branch_id = session.get('branch_id')
    today = date.today().strftime('%Y-%m-%d')
    
    # 1. Daily Sales Summary (Using Functions)
    daily_stats = {'TotalOrders': 0, 'GrossRevenue': 0.0, 'AverageOrderValue': 0.0}
    try:
        daily_stats['TotalOrders'] = db.session.execute(
            text("SELECT GetBranchOrderCount(:branch_id, :target_date)"),
            {'branch_id': branch_id, 'target_date': today}
        ).scalar() or 0
        
        daily_stats['GrossRevenue'] = float(db.session.execute(
            text("SELECT GetBranchRevenue(:branch_id, :target_date)"),
            {'branch_id': branch_id, 'target_date': today}
        ).scalar() or 0.0)
        
        daily_stats['AverageOrderValue'] = float(db.session.execute(
            text("SELECT GetBranchAvgOrderValue(:branch_id, :target_date)"),
            {'branch_id': branch_id, 'target_date': today}
        ).scalar() or 0.0)
        
    except Exception as e:
        print(f"Function Error: {e}")
    
    # 2. Top 5 Dishes using SQL aggregations via SQLAlchemy
    top_dishes = db.session.query(
        MenuItem.item_name, 
        func.sum(OrderItem.quantity).label('total_sold')
    ).join(OrderItem, OrderItem.menu_item_id == MenuItem.menu_item_id)\
     .join(Order, Order.order_id == OrderItem.order_id)\
     .filter(Order.branch_id == branch_id)\
     .group_by(MenuItem.item_name)\
     .order_by(func.sum(OrderItem.quantity).desc())\
     .limit(5).all()
     
    # 3. Waiter Performance
    waiter_perf = db.session.query(
        Staff.first_name,
        func.count(Order.order_id).label('orders_handled'),
        func.sum(Order.subtotal).label('total_revenue')
    ).join(Order, Order.staff_id == Staff.staff_id)\
     .filter(Order.branch_id == branch_id, Staff.role_id == 5)\
     .group_by(Staff.first_name)\
     .order_by(func.sum(Order.subtotal).desc()).all()
     
    return render_template('reports.html', 
                           daily_stats=daily_stats, 
                           top_dishes=top_dishes,
                           waiter_perf=waiter_perf,
                           today=today)
