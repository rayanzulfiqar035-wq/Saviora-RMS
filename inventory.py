from flask import Blueprint, render_template, session, flash, redirect, url_for
from flask_login import login_required, current_user
from models import db, BranchInventory, InventoryItem, IngredientCatalog, Supplier
from sqlalchemy.orm import joinedload

inventory_bp = Blueprint('inventory', __name__, url_prefix='/inventory')

@inventory_bp.route('/')
@login_required
def dashboard():
    # Only Admin, Manager can see Inventory
    if session.get('role_id') not in [1, 2]:
        flash("You do not have permission to view the inventory.", "danger")
        return redirect(url_for('index'))
        
    branch_id = session.get('branch_id')
    
    # Master-Detail join: Fetch Branch Inventory and its items
    inventory_record = BranchInventory.query.filter_by(branch_id=branch_id).first()
    
    if not inventory_record:
        flash("No inventory record found for this branch.", "warning")
        return render_template('inventory.html', inventory=None, items=[])
        
    # Eager load the relationships to avoid N+1 queries
    items = InventoryItem.query.filter_by(inventory_id=inventory_record.inventory_id)\
                .options(joinedload(InventoryItem.ingredient), joinedload(InventoryItem.supplier)).all()
                
    # Prepare data for the UI, checking low stock
    inventory_data = []
    low_stock_count = 0
    
    for item in items:
        qty = float(item.quantity_on_hand)
        min_threshold = float(item.ingredient.global_min_threshold)
        
        is_low = qty <= min_threshold
        if is_low:
            low_stock_count += 1
            
        inventory_data.append({
            'name': item.ingredient.ingredient_name,
            'qty': qty,
            'unit': item.ingredient.measurement_unit,
            'min_threshold': min_threshold,
            'is_low_stock': is_low,
            'supplier_name': item.supplier.supplier_name,
            'supplier_contact': item.supplier.contact_name,
            'supplier_phone': item.supplier.phone
        })
        
    return render_template('inventory.html', 
                           inventory=inventory_record, 
                           items=inventory_data, 
                           low_stock_count=low_stock_count)
