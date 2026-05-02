from flask import Blueprint, render_template, request, session, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from models import db, DiningTable, MenuItem, Order, OrderItem, OrderItemModification, IngredientCatalog, Recipe, Branch, MenuIngredientSubstitution
from datetime import datetime

orders_bp = Blueprint('orders', __name__, url_prefix='/orders')

@orders_bp.route('/table_map')
@login_required
def table_map():
    # Waiters, Managers, Assistant Managers, Cashiers can see this
    if session.get('role_id') in [3, 4, 7, 9]: # Chef, Cleaner, Rider cannot see table map
        flash("Unauthorized access.", "danger")
        return redirect(url_for('index'))
        
    branch_id = session.get('branch_id')
    
    # Fetch all physical tables for the branch
    tables = DiningTable.query.filter_by(branch_id=branch_id).filter(DiningTable.table_number > 0).all()
    
    # Fetch active takeaway orders
    takeaway_orders = Order.query.filter_by(branch_id=branch_id, order_type='Takeaway').filter(Order.order_state != 'Completed').all()
    
    return render_template('table_map.html', tables=tables, takeaway_orders=takeaway_orders)

@orders_bp.route('/takeaway')
@login_required
def takeaway():
    branch_id = session.get('branch_id')
    # Find a virtual table for this branch (e.g. 999, 1999)
    virtual_table = DiningTable.query.filter_by(branch_id=branch_id, table_state='Virtual').first()
    
    if not virtual_table:
        flash("Takeaway is not configured for this branch.", "danger")
        return redirect(url_for('orders.table_map'))
        
    return redirect(url_for('orders.order_entry', table_id=virtual_table.table_id))

@orders_bp.route('/checkout-table/<int:table_id>')
@login_required
def checkout_table(table_id):
    # Security: Verify table belongs to this branch
    table = DiningTable.query.get_or_404(table_id)
    if table.branch_id != session.get('branch_id'):
        flash("Unauthorized access to table.", "danger")
        return redirect(url_for('orders.table_map'))

    # Find the most recent active order for this table
    from models import Order
    order = Order.query.filter_by(table_id=table_id).filter(Order.order_state != 'Completed').order_by(Order.order_id.desc()).first()

    if order:
        return redirect(url_for('billing.checkout', order_id=order.order_id))
    else:
        flash("No active order found for this table.", "warning")
        return redirect(url_for('orders.table_map'))

@orders_bp.route('/entry/<int:table_id>')
@login_required
def order_entry(table_id):
    # Security: Verify table belongs to this branch
    table = DiningTable.query.get_or_404(table_id)
    if table.branch_id != session.get('branch_id'):
        flash("Unauthorized access to table.", "danger")
        return redirect(url_for('orders.table_map'))

    menu_items = MenuItem.query.all()
    
    # Fetch active order for this table if exists
    active_order = Order.query.filter_by(table_id=table_id, order_state='Pending').first()
    
    return render_template('order_entry.html', table=table, menu_items=menu_items, active_order=active_order)

@orders_bp.route('/kitchen')
@login_required
def kitchen_display():
    # Managers, Assistants, and Chefs can see Kitchen Display
    if session.get('role_id') not in [1, 2, 3, 4]: 
        flash("Unauthorized access.", "danger")
        return redirect(url_for('index'))
        
    branch_id = session.get('branch_id')
    
    # Fetch orders that are Pending or Preparing for this branch
    active_orders = Order.query.filter(
        Order.branch_id == branch_id,
        Order.order_state.in_(['Pending', 'Preparing'])
    ).order_by(Order.order_timestamp.asc()).all()
    
    return render_template('kitchen_display.html', orders=active_orders)

# --- API Endpoints for AJAX ---

@orders_bp.route('/api/menu/<int:item_id>/ingredients')
@login_required
def get_item_ingredients(item_id):
    """
    Returns ingredients for a menu item along with their valid substitutions,
    sourced exclusively from MENU_INGREDIENT_SUBSTITUTION for accuracy.
    """
    recipes = Recipe.query.filter_by(menu_item_id=item_id).all()
    ingredients = []
    for r in recipes:
        ing = IngredientCatalog.query.get(r.ingredient_id)

        # Query ONLY valid substitutions for THIS specific dish from the new table
        sub_rules = MenuIngredientSubstitution.query.filter_by(
            menu_item_id=item_id,
            original_ingredient_id=ing.ingredient_id
        ).all()

        substitutes = [{
            'substitution_id': s.substitution_id,
            'id':              s.replacement_ingredient_id,
            'name':            s.replacement_ingredient.ingredient_name,
            'extra_cost':      float(s.extra_cost)
        } for s in sub_rules]

        ingredients.append({
            'recipe_id':     r.recipe_id,
            'ingredient_id': ing.ingredient_id,
            'name':          ing.ingredient_name,
            'substitutes':   substitutes
        })
    return jsonify(ingredients)

@orders_bp.route('/api/place_order', methods=['POST'])
@login_required
def place_order():
    data = request.json
    table_id = data.get('table_id')
    cart = data.get('cart', [])
    
    if not cart:
        return jsonify({'status': 'error', 'message': 'Cart is empty'})
        
    try:
        # Check for existing pending order (only for Dine-In)
        table = DiningTable.query.get(table_id)
        if table.table_state == 'Virtual':
            order = None # Always create a new order for Takeaway
        else:
            order = Order.query.filter_by(table_id=table_id, order_state='Pending').first()
        
        # If no order exists, create one
        if not order:
            order = Order(
                table_id=table_id,
                staff_id=current_user.staff_id,
                branch_id=session.get('branch_id'),
                order_state='Pending',
                order_type='Takeaway' if DiningTable.query.get(table_id).table_state == 'Virtual' else 'Dine-In'
            )
            db.session.add(order)
            db.session.flush() # Get order_id
            
            # Update table state if dine-in
            if order.order_type == 'Dine-In':
                table = DiningTable.query.get(table_id)
                table.table_state = 'Occupied'
                
        # Add items and modifications
        for item in cart:
            menu_item = MenuItem.query.get(item['menu_item_id'])
            order_item = OrderItem(
                order_id=order.order_id,
                menu_item_id=menu_item.menu_item_id,
                quantity=item['quantity'],
                unit_price=menu_item.base_price
            )
            db.session.add(order_item)
            db.session.flush()
            
            # Handle modifications — validate each swap against MENU_INGREDIENT_SUBSTITUTION
            for mod in item.get('modifications', []):
                menu_item_id_for_mod = item['menu_item_id']

                # Integrity check: only accept swaps that exist in the substitution table
                rule = MenuIngredientSubstitution.query.filter_by(
                    menu_item_id=menu_item_id_for_mod,
                    original_ingredient_id=mod['removed_id'],
                    replacement_ingredient_id=mod['added_id']
                ).first()

                if not rule:
                    # Silently skip invalid swaps — they should never arrive from our UI
                    continue

                # Use extra_cost from the authoritative DB table, not the client
                extra_cost = float(rule.extra_cost) * item['quantity']

                modification = OrderItemModification(
                    order_item_id=order_item.order_item_id,
                    removed_ingredient_id=rule.original_ingredient_id,
                    added_ingredient_id=rule.replacement_ingredient_id,
                    mod_quantity=item['quantity'],
                    extra_cost=extra_cost
                )
                db.session.add(modification)
                
        db.session.commit()
        return jsonify({'status': 'success', 'order_id': order.order_id})
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'status': 'error', 'message': str(e)})

@orders_bp.route('/api/update_state/<int:order_id>', methods=['POST'])
@login_required
def update_order_state(order_id):
    # Managers, Assistants, Chefs, and Waiters can update state
    if session.get('role_id') not in [1, 2, 3, 4, 5]:
        return jsonify({'status': 'error', 'message': 'Unauthorized'})
        
    data = request.json
    new_state = data.get('state')
    
    order = Order.query.get_or_404(order_id)
    order.order_state = new_state
    
    # If order is served, table might still be occupied until payment
    
    db.session.commit()
    return jsonify({'status': 'success'})
