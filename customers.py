from flask import Blueprint, render_template, request, session, redirect, url_for, flash
from flask_login import login_required
from models import db, Customer, RewardTier

customers_bp = Blueprint('customers', __name__, url_prefix='/customers')

@customers_bp.route('/')
@login_required
def list_customers():
    customers = Customer.query.order_by(Customer.total_points.desc()).all()
    return render_template('customers_list.html', customers=customers)

@customers_bp.route('/register', methods=['GET', 'POST'])
@login_required
def register():
    if request.method == 'POST':
        name = request.form.get('name')
        phone = request.form.get('phone')
        
        # Check if phone already exists
        existing = Customer.query.filter_by(phone=phone).first()
        if existing:
            flash(f"Customer with phone {phone} already exists (Name: {existing.name}).", "warning")
            return redirect(url_for('customers.list_customers'))
            
        try:
            # Create new customer (default to Starter Tier 1)
            new_customer = Customer(
                tier_id=1,
                name=name,
                phone=phone,
                total_points=0
            )
            db.session.add(new_customer)
            db.session.commit()
            flash("Customer registered successfully!", "success")
            return redirect(url_for('customers.list_customers'))
        except Exception as e:
            db.session.rollback()
            flash(f"Error registering customer: {str(e)}", "danger")
            
    return render_template('register_customer.html')
