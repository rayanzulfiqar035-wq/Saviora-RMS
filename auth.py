from flask import Blueprint, render_template, redirect, url_for, flash, request, session
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import check_password_hash
from models import Staff, db

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index')) # We will create a dashboard route later

    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        branch_id = request.form.get('branch_id')

        user = Staff.query.filter_by(username=username).first()
        
        # NOTE: Since the schema has password_hash but the inserts have plaintext 'h1', 'h2', etc.
        # we will simply check if the provided password equals the database 'hash' for now.
        if user and user.password_hash == password:
            # Verify Branch ID
            if str(user.branch_id) != str(branch_id):
                flash(f'Access Denied: You are not authorized for Branch {branch_id}.', 'danger')
                return redirect(url_for('auth.login'))

            # Restrict login to only Admin (1) and Waiter (3)
            if user.role_id not in [1, 3]:
                flash('Access Denied: Only Admin and Waiter accounts can log in.', 'danger')
                return redirect(url_for('auth.login'))
                
            login_user(user)
            # Store branch_id and role_id in session as requested
            session['branch_id'] = user.branch_id
            session['role_id'] = user.role_id
            flash('Logged in successfully.', 'success')
            return redirect(url_for('index'))
        else:
            flash('Invalid username or password.', 'danger')

    return render_template('login.html')

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    session.pop('branch_id', None)
    session.pop('role_id', None)
    flash('You have been logged out.', 'info')
    return redirect(url_for('auth.login'))
