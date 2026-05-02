from flask import Blueprint, render_template, request, session, redirect, url_for, flash
from flask_login import login_required, current_user
from models import db, Reservation, DiningTable, Customer
from datetime import datetime

reservations_bp = Blueprint('reservations', __name__, url_prefix='/reservations')

@reservations_bp.route('/')
@login_required
def list_reservations():
    branch_id = session.get('branch_id')
    # Filter reservations by joining with DiningTable to ensure they belong to this branch
    upcoming = Reservation.query.join(DiningTable).filter(
        DiningTable.branch_id == branch_id,
        Reservation.reservation_date >= datetime.today().date()
    ).order_by(Reservation.reservation_date.asc(), Reservation.reservation_time.asc()).all()
    
    return render_template('reservations_list.html', reservations=upcoming)

@reservations_bp.route('/new', methods=['GET', 'POST'])
@login_required
def new_reservation():
    branch_id = session.get('branch_id')
    available_tables = DiningTable.query.filter_by(branch_id=branch_id).filter(DiningTable.table_number > 0).all()
    
    if request.method == 'POST':
        customer_phone = request.form.get('phone')
        table_id = request.form.get('table_id')
        res_date = request.form.get('date')
        res_time = request.form.get('time')
        party_size = request.form.get('party_size')
        
        # Security: Verify table belongs to this branch
        table = DiningTable.query.get_or_404(table_id)
        if table.branch_id != session.get('branch_id'):
            flash("Unauthorized access to table.", "danger")
            return redirect(url_for('reservations.list_reservations'))

        # 1. Check if customer exists
        customer = Customer.query.filter_by(phone=customer_phone).first()
        if not customer:
            # Simple customer creation if not found
            name = request.form.get('customer_name')
            if not name:
                flash("New customer detected. Please provide a name.", "warning")
                return render_template('reservation_form.html', tables=available_tables)
            
            customer = Customer(tier_id=1, name=name, phone=customer_phone)
            db.session.add(customer)
            db.session.flush()

        # 2. Check if table is already booked for that time (Simplified check)
        existing = Reservation.query.filter_by(
            table_id=table_id, 
            reservation_date=res_date, 
            reservation_time=res_time
        ).first()
        
        if existing:
            flash("This table is already reserved for the selected time.", "danger")
            return render_template('reservation_form.html', tables=available_tables)

        # 3. Create Reservation
        new_res = Reservation(
            customer_id=customer.customer_id,
            table_id=table_id,
            reservation_date=datetime.strptime(res_date, '%Y-%m-%d').date(),
            reservation_time=datetime.strptime(res_time, '%H:%M').time(),
            party_size=party_size
        )
        db.session.add(new_res)
        db.session.commit()
        
        flash("Reservation confirmed successfully!", "success")
        return redirect(url_for('reservations.list_reservations'))

    return render_template('reservation_form.html', tables=available_tables)
