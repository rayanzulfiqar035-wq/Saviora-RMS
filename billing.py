from flask import Blueprint, render_template, request, session, redirect, url_for, flash
from flask_login import login_required
from models import db, Order, Payment, Customer, RewardTier
from datetime import datetime

billing_bp = Blueprint('billing', __name__, url_prefix='/billing')

@billing_bp.route('/checkout/<int:order_id>', methods=['GET', 'POST'])
@login_required
def checkout(order_id):
    order = Order.query.get_or_404(order_id)
    
    # Security: Verify order belongs to this branch
    if order.branch_id != session.get('branch_id'):
        flash("Unauthorized access to order.", "danger")
        return redirect(url_for('orders.table_map'))

    if order.order_state == 'Completed':
        flash('This order has already been paid and completed.', 'warning')
        return redirect(url_for('orders.table_map'))

    if request.method == 'POST':
        customer_phone = request.form.get('customer_phone')
        payment_method = request.form.get('payment_method')
        
        customer = Customer.query.filter_by(phone=customer_phone).first()
        if not customer:
            flash('Customer not found. Please register first.', 'danger')
            return redirect(url_for('billing.checkout', order_id=order_id))
            
        discount_applied = 0.00
        tier = RewardTier.query.get(customer.tier_id)
        if tier:
            # Assuming discount_per_point is a percentage or fixed amount
            # The schema describes discount_per_point as DECIMAL(5,2). Let's treat it as percentage discount e.g. 0.05 is 5%
            discount_applied = float(order.subtotal) * float(tier.discount_per_point)
            
        final_amount = float(order.subtotal) - discount_applied
        
        # Start Transaction using db.session
        try:
            # Create Payment record
            payment = Payment(
                order_id=order.order_id,
                customer_id=customer.customer_id,
                payment_method=payment_method,
                subtotal_amount=order.subtotal,
                discount_applied=discount_applied,
                final_amount=final_amount,
                payment_timestamp=datetime.utcnow()
            )
            db.session.add(payment)
            db.session.flush() # ensure payment is staged
            
            # Call Stored Procedure CompleteOrderAndDeductStock(order_id)
            # SQLAlchemy text() is required for raw SQL
            from sqlalchemy import text
            db.session.execute(text("CALL CompleteOrderAndDeductStock(:order_id)"), {'order_id': order.order_id})
            
            db.session.commit()
            
            # The trg_after_payment_insert trigger handles total_points update
            points_earned = int(final_amount // 10)
            flash(f'Payment Successful! Customer earned {points_earned} loyalty points.', 'success')
            return redirect(url_for('orders.table_map'))
            
        except Exception as e:
            db.session.rollback()
            flash(f'Transaction failed: {str(e)}', 'danger')
            return redirect(url_for('billing.checkout', order_id=order_id))

    return render_template('checkout.html', order=order)
